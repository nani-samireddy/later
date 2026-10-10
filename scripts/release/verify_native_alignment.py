#!/usr/bin/env python3
"""Check PT_LOAD alignment of every 64-bit native library packaged in an APK."""
import argparse
import struct
import zipfile

parser = argparse.ArgumentParser()
parser.add_argument('apk')
args = parser.parse_args()
checked = 0
failures = []
with zipfile.ZipFile(args.apk) as archive:
    for name in archive.namelist():
        if not name.startswith(('lib/arm64-v8a/', 'lib/x86_64/')) or not name.endswith('.so'):
            continue
        data = archive.read(name)
        if data[:5] != b'\x7fELF\x02':
            failures.append(name + ': expected 64-bit ELF')
            continue
        endian = '<' if data[5] == 1 else '>'
        offset = struct.unpack_from(endian + 'Q', data, 32)[0]
        size, count = struct.unpack_from(endian + 'HH', data, 54)
        loads = []
        for index in range(count):
            values = struct.unpack_from(endian + 'IIQQQQQQ', data, offset + index * size)
            if values[0] == 1:
                loads.append(values[7])
        if not loads or any(alignment < 16384 for alignment in loads):
            failures.append(name + ': PT_LOAD alignment below 16 KB')
        checked += 1
if not checked:
    raise SystemExit('No 64-bit native libraries found')
if failures:
    raise SystemExit('\n'.join(failures))
print(f'16 KB ELF alignment verified for {checked} packaged 64-bit libraries.')
