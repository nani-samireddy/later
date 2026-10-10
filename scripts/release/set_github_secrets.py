#!/usr/bin/env python3
"""Explicitly invoked helper: transmit secrets to GitHub over stdin, never output values."""
import argparse
import base64
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--directory', type=Path, required=True)
parser.add_argument('--repo', required=True, help='OWNER/REPOSITORY')
args = parser.parse_args()
properties = dict(line.split('=', 1) for line in (args.directory.expanduser() / 'key.properties').read_text().splitlines() if '=' in line)
values = {
    'ANDROID_UPLOAD_KEYSTORE_BASE64': base64.b64encode(Path(properties['storeFile']).read_bytes()).decode(),
    'ANDROID_KEYSTORE_PASSWORD': properties['storePassword'],
    'ANDROID_KEY_ALIAS': properties['keyAlias'],
    'ANDROID_KEY_PASSWORD': properties['keyPassword'],
}
for name, value in values.items():
    subprocess.run(['gh', 'secret', 'set', name, '--env', 'android-release', '--repo', args.repo], input=value, text=True, check=True)
print('Four environment secrets set; no credentials displayed.')
