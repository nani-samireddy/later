#!/usr/bin/env python3
"""Validate immutable Android tags and prevent version-code reuse/downgrades."""
import argparse
import re
import subprocess

PATTERN = re.compile(r"android-v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-rc\.([1-9]\d*))?\+([1-9]\d*)")

def parse(tag):
    match = PATTERN.fullmatch(tag)
    if not match:
        raise ValueError("Expected android-vMAJOR.MINOR.PATCH[-rc.N]+VERSION_CODE")
    major, minor, patch, rc, code = match.groups()
    if int(code) > 2100000000:
        raise ValueError("versionCode exceeds Google Play limit")
    return (int(major), int(minor), int(patch), int(rc) if rc else float('inf')), int(code), tag.removeprefix('android-v').split('+')[0]

def validate(tag, tags):
    version, code, name = parse(tag)
    for previous in tags:
        if previous == tag or not PATTERN.fullmatch(previous):
            continue
        old_version, old_code, _ = parse(previous)
        if code <= old_code:
            raise ValueError(f"versionCode must exceed existing release {previous}")
        if version <= old_version:
            raise ValueError(f"Version must advance beyond existing release {previous}")
    return name, code

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('tag')
    args = parser.parse_args()
    tags = subprocess.check_output(['git', 'tag', '--list', 'android-v*'], text=True).splitlines()
    try:
        name, code = validate(args.tag, tags)
    except ValueError as error:
        parser.error(str(error))
    print(f'build_name={name}\nbuild_number={code}')
