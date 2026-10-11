#!/usr/bin/env python3
"""Reject broad media/storage permissions in a packaged Android APK."""
import argparse
import subprocess

FORBIDDEN = {
    'android.permission.READ_MEDIA_IMAGES',
    'android.permission.READ_MEDIA_VIDEO',
    'android.permission.READ_MEDIA_AUDIO',
    'android.permission.READ_EXTERNAL_STORAGE',
    'android.permission.WRITE_EXTERNAL_STORAGE',
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('apk')
    parser.add_argument('--aapt', required=True)
    args = parser.parse_args()
    result = subprocess.run(
        [args.aapt, 'dump', 'permissions', args.apk],
        capture_output=True, text=True, check=True,
    )
    found = sorted(permission for permission in FORBIDDEN if permission in result.stdout)
    if found:
        raise SystemExit('Unexpected broad storage permissions: ' + ', '.join(found))
    print('Packaged APK has no broad media or storage permissions.')


if __name__ == '__main__':
    main()
