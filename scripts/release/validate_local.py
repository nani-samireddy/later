#!/usr/bin/env python3
"""Build and verify both release artifacts using private properties through env only."""
import argparse
import os
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--directory', type=Path, required=True)
parser.add_argument('--java-home', type=Path, required=True)
parser.add_argument('--build-name', required=True)
parser.add_argument('--build-number', required=True)
args = parser.parse_args()
properties = dict(line.split('=', 1) for line in (args.directory.expanduser() / 'key.properties').read_text().splitlines() if '=' in line)
env = os.environ.copy()
for name, property_name in [('ANDROID_KEYSTORE_PATH', 'storeFile'), ('ANDROID_KEYSTORE_PASSWORD', 'storePassword'), ('ANDROID_KEY_ALIAS', 'keyAlias'), ('ANDROID_KEY_PASSWORD', 'keyPassword')]: env[name] = properties[property_name]
env['JAVA_HOME'] = str(args.java_home)
env['PATH'] = str(args.java_home / 'bin') + os.pathsep + env['PATH']
for artifact in ['appbundle', 'apk']:
    subprocess.run(['flutter', 'build', artifact, '--release', '--build-name', args.build_name, '--build-number', args.build_number], env=env, check=True)
result = subprocess.run([str(args.java_home / 'bin/jarsigner'), '-verify', 'build/app/outputs/bundle/release/app-release.aab'], env=env, capture_output=True, text=True, check=True)
if 'jar verified' not in result.stdout: raise SystemExit('AAB is not signed')
sdk = Path(next(line.split('=', 1)[1] for line in Path('android/local.properties').read_text().splitlines() if line.startswith('sdk.dir=')))
build_tools = sorted((sdk / 'build-tools').iterdir(), key=lambda p: tuple(int(n) for n in p.name.split('.')))[-1]
subprocess.run([str(build_tools / 'apksigner'), 'verify', '--verbose', 'build/app/outputs/flutter-apk/app-release.apk'], env=env, check=True)
subprocess.run([str(build_tools / 'zipalign'), '-c', '-P', '16', '4', 'build/app/outputs/flutter-apk/app-release.apk'], env=env, check=True)
subprocess.run(['python3', 'scripts/release/verify_media_permissions.py', 'build/app/outputs/flutter-apk/app-release.apk', '--aapt', str(build_tools / 'aapt')], check=True)
subprocess.run(['python3', 'scripts/release/verify_native_alignment.py', 'build/app/outputs/flutter-apk/app-release.apk'], check=True)
print('Signed AAB and APK built and verified; APK ZIP and ELF alignment checked.')
