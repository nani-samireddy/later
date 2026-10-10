#!/usr/bin/env python3
"""Drive the real Android camera for the camera integration test."""
import os
from pathlib import Path
import re
import shutil
import subprocess
import time
import xml.etree.ElementTree as ET

ADB = shutil.which('adb') or str(Path.home() / 'Library/Android/sdk/platform-tools/adb')
DEVICE = os.environ.get('LATER_QA_DEVICE', 'emulator-5554')


def android(*args):
    return subprocess.check_output([ADB, '-s', DEVICE, *args], text=True, timeout=30)


def drive_camera(cancel=False):
    captured = False
    for _ in range(40):
        android('shell', 'uiautomator', 'dump', '/sdcard/later-camera-qa.xml')
        contents = android('exec-out', 'cat', '/sdcard/later-camera-qa.xml')
        try:
            nodes = list(ET.fromstring(contents).iter('node'))
        except ET.ParseError:
            # Android can report a null accessibility root during transitions.
            time.sleep(.5)
            continue
        camera_nodes = [n for n in nodes if 'camera' in n.get('package', '').lower()]
        if cancel and camera_nodes:
            android('shell', 'input', 'keyevent', '4')
            return
        candidates = []
        permission_text = ' '.join(n.get('text', '').lower() for n in nodes)
        for node in nodes:
            label = (node.get('content-desc', '') or node.get('text', '')).lower()
            resource = node.get('resource-id', '').lower()
            if node.get('text') == 'Wait' and "isn't responding" in permission_text:
                candidates.insert(0, node)
            elif ('permission' in node.get('package', '') and
                    any(part in permission_text for part in ['location', 'audio']) and
                    label in ["don't allow", 'deny']):
                candidates.insert(0, node)
            elif ('permission' in node.get('package', '') and
                    not any(part in permission_text for part in ['location', 'audio']) and
                    any(part in label for part in ['while using', 'only this time', 'allow'])):
                candidates.append(node)
            elif camera_nodes and any(part in label for part in ['shutter', 'take photo', 'capture']):
                candidates.append(node)
            elif camera_nodes and any(part in resource for part in ['shutter_button', 'shutterbutton']):
                candidates.append(node)
            elif camera_nodes and (label in ['done', 'ok', 'save', 'accept', 'use photo'] or
                                   any(part in resource for part in ['done_button', 'donebutton'])):
                candidates.insert(0, node)
        if candidates:
            node = candidates[0]
            bounds = re.fullmatch(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', node.get('bounds', ''))
            if bounds:
                x1, y1, x2, y2 = map(int, bounds.groups())
                android('shell', 'input', 'tap', str((x1+x2)//2), str((y1+y2)//2))
                captured = True
                time.sleep(1)
        elif captured and not camera_nodes:
            return
        time.sleep(.25)
    raise RuntimeError('Camera did not finish; inspect /sdcard/later-camera-qa.xml')


def main():
    root = Path(__file__).resolve().parents[1]
    share_uri = None
    share_path = None
    command = ['flutter', 'test', '-d', DEVICE, '--no-pub', '--no-uninstall']
    cleanup_title = os.environ.get('LATER_QA_CLEANUP_TITLE')
    if cleanup_title:
        command.append('--dart-define=LATER_QA_CLEANUP_TITLE=' + cleanup_title)
    command.append('integration_test/capture_android_test.dart')
    process = subprocess.Popen(command, cwd=root,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
    try:
        for line in process.stdout:
            print(line, end='', flush=True)
            if 'QA_CAMERA_CAPTURE' in line:
                drive_camera()
            elif 'QA_CAMERA_CANCEL' in line:
                drive_camera(cancel=True)
            elif 'QA_UNREADABLE_SHARE' in line:
                unavailable = 'content://media/external/images/media/2147483647'
                android('shell', 'am', 'start', '-W', '-n', 'com.nanisamireddy.later/.MainActivity',
                        '-a', 'android.intent.action.SEND', '-t', 'image/png',
                        '-d', unavailable, '--eu', 'android.intent.extra.STREAM', unavailable)
            elif 'QA_SHARED_SCREENSHOT' in line:
                fixture = root / 'integration_test/fixtures/payment_paid.png'
                fixture_name = f'later-payment-qa-{int(time.time()*1000)}.png'
                share_path = '/sdcard/Pictures/' + fixture_name
                android('push', str(fixture), share_path)
                android('shell', 'am', 'broadcast', '-a', 'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
                        '-d', 'file://' + share_path)
                uri = None
                for _ in range(10):
                    rows = android('shell', 'content', 'query', '--uri', 'content://media/external/images/media',
                                   '--projection', '_id:_display_name')
                    match = re.search(r'_id=(\d+), _display_name=' + re.escape(fixture_name), rows)
                    if match:
                        uri = 'content://media/external/images/media/' + match.group(1)
                        break
                    time.sleep(.5)
                if uri is None:
                    raise RuntimeError('Synthetic share fixture was not indexed')
                share_uri = uri
                android('shell', 'am', 'start', '-W', '-n', 'com.nanisamireddy.later/.MainActivity',
                        '-a', 'android.intent.action.SEND', '-t', 'image/png',
                        '-d', uri,
                        '--eu', 'android.intent.extra.STREAM', uri, '--grant-read-uri-permission')
        if process.wait() != 0:
            raise RuntimeError('Camera verification failed')
    finally:
        if process.poll() is None:
            process.terminate()
            process.wait(timeout=30)
        if share_uri:
            android('shell', 'content', 'delete', '--uri', share_uri)
        if share_path:
            android('shell', 'rm', '-f', share_path)


if __name__ == '__main__':
    main()
