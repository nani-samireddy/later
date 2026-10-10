#!/usr/bin/env python3
"""Verify cold-start screenshot review in the installed normal app; never save."""
import re
import time
import xml.etree.ElementTree as ET
from pathlib import Path
from verify_camera_android import android


def main():
    name = f'later-cold-share-qa-{int(time.time()*1000)}.png'
    device_path = '/sdcard/Pictures/' + name
    uri = None
    try:
        android('push', str(Path(__file__).resolve().parents[1] /
                           'integration_test/fixtures/payment_paid.png'), device_path)
        android('shell', 'am', 'broadcast', '-a', 'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
                '-d', 'file://' + device_path)
        for _ in range(20):
            rows = android('shell', 'content', 'query', '--uri', 'content://media/external/images/media',
                           '--projection', '_id:_display_name')
            match = re.search(r'_id=(\d+), _display_name=' + re.escape(name), rows)
            if match:
                uri = 'content://media/external/images/media/' + match.group(1)
                break
            time.sleep(.5)
        if uri is None:
            raise RuntimeError('QA fixture was not indexed')
        android('shell', 'am', 'force-stop', 'com.nanisamireddy.later')
        android('shell', 'am', 'start', '-W', '-n', 'com.nanisamireddy.later/.MainActivity',
                '-a', 'android.intent.action.SEND', '-t', 'image/png', '-d', uri,
                '--eu', 'android.intent.extra.STREAM', uri, '--grant-read-uri-permission')
        for _ in range(30):
            android('shell', 'uiautomator', 'dump', '/sdcard/later-cold-share-qa.xml')
            try:
                nodes = list(ET.fromstring(android('exec-out', 'cat',
                                                  '/sdcard/later-cold-share-qa.xml')).iter('node'))
            except ET.ParseError:
                continue
            text = ' '.join(n.get('text', '') for n in nodes)
            if 'Asha Rao' in text and '1250.50' in text:
                checks = [n for n in nodes if n.get('class') == 'android.widget.CheckBox']
                if not checks or any(n.get('checked') == 'true' for n in checks):
                    raise RuntimeError('Payment confirmation was not initially unchecked')
                android('shell', 'input', 'keyevent', '4')
                print('Cold share OCR review passed; canceled without saving.')
                return
            time.sleep(1)
        raise RuntimeError('Cold share did not open the expected editable OCR review')
    finally:
        if uri:
            android('shell', 'content', 'delete', '--uri', uri)
        android('shell', 'rm', '-f', device_path)


if __name__ == '__main__':
    main()
