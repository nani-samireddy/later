#!/usr/bin/env python3
"""Pair/connect a verified Pixel 6a and run Later without changing phone data."""
import argparse
import getpass
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def fail(message):
    raise RuntimeError(message)


def locate(name):
    found = shutil.which(name)
    if found:
        return found
    props = {}
    local = ROOT / 'android/local.properties'
    if local.exists():
        props = dict(line.split('=', 1) for line in local.read_text().splitlines() if '=' in line)
    if name == 'adb':
        roots = [os.environ.get('ANDROID_HOME', ''), os.environ.get('ANDROID_SDK_ROOT', ''),
                 props.get('sdk.dir', ''), str(Path.home() / 'Library/Android/sdk'),
                 str(Path.home() / 'Android/Sdk')]
        candidates = [Path(p) / 'platform-tools/adb' for p in roots if p]
    else:
        candidates = [Path(props.get('flutter.sdk', '/nonexistent')) / 'bin/flutter']
    for candidate in candidates:
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate)
    fail(f'{name} not found. Add it to PATH or configure android/local.properties.')


def address(value):
    if not re.fullmatch(r'(?:[^\s:]+|\[[0-9a-fA-F:]+\]):[0-9]+', value):
        raise argparse.ArgumentTypeError('Expected HOST:PORT from the phone screen.')
    if not 1 <= int(value.rsplit(':', 1)[1]) <= 65535:
        raise argparse.ArgumentTypeError('Port must be between 1 and 65535.')
    return value


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pair-address', type=address)
    parser.add_argument('--connect-address', type=address)
    parser.add_argument('--device', help='Exact already-connected ADB serial')
    parser.add_argument('--discover', action='store_true', help='List devices/services and exit')
    parser.add_argument('--connect-only', action='store_true')
    parser.add_argument('--apk', type=Path, default=ROOT / 'build/app/outputs/flutter-apk/app-debug.apk', help='Existing debug APK (defaults to build/app/outputs/flutter-apk/app-debug.apk); avoids Gradle')
    parser.add_argument('--timeout', type=int, default=20, help='ADB command timeout in seconds')
    args = parser.parse_args()
    if args.timeout <= 0:
        parser.error('--timeout must be positive')
    adb = locate('adb')

    def call(*command, secret=None):
        try:
            result = subprocess.run([adb, *command], input=secret, text=True,
                                    capture_output=True, timeout=max(args.timeout, 300) if 'install' in command else args.timeout)
        except subprocess.TimeoutExpired:
            fail(f'ADB {command[0]} timed out. Check Wi-Fi and Wireless debugging, then retry.')
        output = result.stdout + result.stderr
        if result.returncode:
            # Pair output is intentionally suppressed: never echo a pairing secret.
            if 'INSTALL_FAILED_UPDATE_INCOMPATIBLE' in output:
                fail('Signing conflict: the installed app uses a different signing key. Its data has been preserved. Use the original key or a separate application ID; do not uninstall or clear data.')
            fail('Pairing failed. Reopen the pairing dialog and retry.' if secret else output.strip())
        return output.strip()

    def devices():
        return [line.split()[0] for line in call('devices').splitlines()[1:]
                if len(line.split()) >= 2 and line.split()[1] == 'device']

    def services():
        return call('mdns', 'services')

    if args.discover:
        print(call('devices', '-l'))
        print(services())
        return
    if args.pair_address:
        if not sys.stdin.isatty():
            fail('Pair interactively in a terminal so the pairing code stays hidden.')
        code = getpass.getpass('Pairing code from your Pixel 6a: ')
        if not re.fullmatch(r'\d{6}', code):
            fail('Expected the six-digit pairing code.')
        output = call('pair', args.pair_address, secret=code + '\n')
        del code
        if 'Successfully paired' not in output:
            fail('Pairing was not confirmed. Reopen the pairing dialog and retry.')
        print('Pairing succeeded.')

    target = args.device or args.connect_address
    if not target:
        pixels = []
        identities = set()
        for serial in devices():
            if serial.startswith('emulator-'):
                continue
            if call('-s', serial, 'shell', 'getprop', 'ro.product.model') == 'Pixel 6a':
                identity = call('-s', serial, 'shell', 'getprop', 'ro.serialno') or serial
                if identity not in identities:
                    pixels.append(serial)
                    identities.add(identity)
        if len(pixels) == 1:
            target = pixels[0]
        elif len(pixels) > 1:
            fail('Multiple Pixel 6a devices connected. Supply --device with the intended serial.')
        else:
            discovered = services()
            print(discovered)
            if not sys.stdin.isatty():
                fail('Confirm your Pixel’s connection address and pass --connect-address HOST:PORT.')
            target = address(input('Enter the connection address shown on YOUR Pixel 6a: ').strip())
    if target.startswith('emulator-'):
        fail('This helper only deploys to a Pixel 6a; emulator selection is refused.')
    if not args.device:
        print(call('connect', target))
    if target not in devices():
        fail('Device is not connected/authorized. Pair first, or check the current connection port.')
    model = call('-s', target, 'shell', 'getprop', 'ro.product.model')
    manufacturer = call('-s', target, 'shell', 'getprop', 'ro.product.manufacturer')
    hardware = call('-s', target, 'shell', 'getprop', 'ro.product.device')
    if model != 'Pixel 6a' or manufacturer.lower() != 'google' or hardware != 'bluejay':
        fail(f'Refusing deployment: selected device is {manufacturer} {model} ({hardware}), not Pixel 6a.')
    print(f'Verified Google Pixel 6a (bluejay): {target}', flush=True)
    if args.connect_only:
        return
    flutter = locate('flutter')
    command = [flutter, 'run', '--debug', '-d', target]
    if args.apk:
        apk = args.apk.expanduser().resolve()
        if not apk.is_file():
            fail(f'APK not found: {apk}')
        print('Installing existing APK with adb install -r (preserves data)...', flush=True)
        installed = call('-s', target, 'install', '-r', str(apk))
        if 'Success' not in installed:
            fail('APK update failed: ' + installed + '\nPreserve the existing app. A signing conflict requires the original signing key or a separate application ID.')
        print(installed, flush=True)
        command += ['--use-application-binary', str(apk)]
    print('Starting Later on the verified Pixel. Hot reload: r; quit: q.', flush=True)
    result = subprocess.run(command, cwd=ROOT)
    if result.returncode:
        fail('Flutter run failed. If INSTALL_FAILED_UPDATE_INCOMPATIBLE appears, the installed app uses another signing key. Preserve it: use its original key or a separate application ID. Do not uninstall or clear data.')


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, ValueError, EOFError) as error:
        print(f'Error: {error}', file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        sys.exit(130)
