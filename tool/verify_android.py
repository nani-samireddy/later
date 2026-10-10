#!/usr/bin/env python3
"""Run Android milestone tests, including real notification/PDF system UI steps."""
import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import time
import xml.etree.ElementTree as ET


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--device', default='emulator-5554')
    parser.add_argument('--native-only', action='store_true')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    sdk = os.environ.get('ANDROID_SDK_ROOT') or os.environ.get('ANDROID_HOME')
    adb = shutil.which('adb')
    if not adb:
        candidates = [Path(sdk) / 'platform-tools/adb'] if sdk else []
        candidates += [Path.home() / 'Library/Android/sdk/platform-tools/adb',
                       Path.home() / 'Android/Sdk/platform-tools/adb']
        adb = next((str(p) for p in candidates if p.is_file()), None)
    if not adb:
        raise RuntimeError('Set ANDROID_SDK_ROOT or put adb on PATH')

    def android(*command, binary=False):
        return subprocess.check_output([adb, '-s', args.device, *command],
                                       text=not binary, timeout=30)

    def tap_notification(name):
        android('shell', 'cmd', 'statusbar', 'expand-notifications')
        for _ in range(10):
            android('shell', 'uiautomator', 'dump', '/sdcard/later-verification.xml')
            tree = ET.fromstring(android('exec-out', 'cat', '/sdcard/later-verification.xml'))
            for node in tree.iter('node'):
                if node.get('text') == name:
                    bounds = re.fullmatch(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', node.get('bounds', ''))
                    if bounds:
                        x1, y1, x2, y2 = map(int, bounds.groups())
                        android('shell', 'input', 'tap', str((x1+x2)//2), str((y1+y2)//2))
                        print('[verification] Tapped the delivered record notification', flush=True)
                        return
            time.sleep(0.5)
        raise RuntimeError('Delivered notification was not visible in Android system UI')

    def return_from_pdf():
        for _ in range(30):
            activity = android('shell', 'dumpsys', 'activity', 'activities')
            if any('PdfViewerActivity' in line and 'Resumed' in line for line in activity.splitlines()):
                break
            time.sleep(0.25)
        else:
            raise RuntimeError('PDF viewer did not become the foreground activity')
        for _ in range(20):
            android('shell', 'uiautomator', 'dump', '/sdcard/later-verification.xml')
            contents = android('exec-out', 'cat', '/sdcard/later-verification.xml')
            if 'native-qa.pdf' in contents:
                break
            time.sleep(0.25)
        else:
            raise RuntimeError('PDF viewer did not display the copied document title')
        # Wait for the native PDF page's first paint, beyond the activity transition.
        time.sleep(2)
        screenshot = Path(tempfile.gettempdir()) / 'later-verified-pdf-viewer.png' 
        screenshot.write_bytes(android('exec-out', 'screencap', '-p', binary=True))
        print(f'[verification] Android PDF viewer confirmed; screenshot: {screenshot}', flush=True)
        android('shell', 'input', 'keyevent', '4')

    tests = ['integration_test/native_verification_test.dart']
    if not args.native_only:
        tests.insert(0, 'integration_test/milestone_test.dart')
    for test in tests:
        process = subprocess.Popen(['flutter', 'test', '-d', args.device, '--no-pub',
                                    '--no-uninstall', test], cwd=root, stdout=subprocess.PIPE,
                                   stderr=subprocess.STDOUT, text=True, bufsize=1)
        try:
            for line in process.stdout:
                print(line, end='', flush=True)
                if re.search(r'\+0: (Milestone:|Money UI,)', line):
                    sdk_version = int(android('shell', 'getprop', 'ro.build.version.sdk').strip())
                    if sdk_version >= 33:
                        android('shell', 'pm', 'grant', 'com.nanisamireddy.later', 'android.permission.POST_NOTIFICATIONS')
                    if sdk_version >= 31:
                        android('shell', 'appops', 'set', 'com.nanisamireddy.later', 'SCHEDULE_EXACT_ALARM', 'allow')
                if 'QA_NOTIFICATION_READY ' in line:
                    tap_notification(line.split('QA_NOTIFICATION_READY ', 1)[1].strip())
                if 'QA_PDF_READY' in line:
                    return_from_pdf()
            if process.wait() != 0:
                raise RuntimeError(f'Android verification failed: {test}')
        finally:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=30)


if __name__ == '__main__':
    main()
