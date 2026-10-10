#!/usr/bin/env python3
"""Create private upload signing material outside the checkout; never print secrets."""
import argparse
import os
from pathlib import Path
import secrets
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--directory', type=Path, required=True)
parser.add_argument('--keytool', default='keytool')
args = parser.parse_args()
directory = args.directory.expanduser().resolve()
repository = Path(__file__).resolve().parents[2]
if directory == repository or repository in directory.parents:
    parser.error('Signing material must be outside the repository')
os.umask(0o077)
directory.mkdir(mode=0o700, parents=True, exist_ok=False)
password = secrets.token_urlsafe(48)
store = directory / 'upload-keystore.jks'
environment = os.environ.copy()
environment['LATER_GENERATED_PASSWORD'] = password
try:
    subprocess.run([args.keytool, '-genkeypair', '-noprompt', '-storetype', 'JKS', '-keystore', str(store), '-alias', 'upload', '-keyalg', 'RSA', '-keysize', '3072', '-validity', '10000', '-dname', 'CN=Later Upload Key', '-storepass:env', 'LATER_GENERATED_PASSWORD', '-keypass:env', 'LATER_GENERATED_PASSWORD'], env=environment, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    subprocess.run([args.keytool, '-exportcert', '-rfc', '-keystore', str(store), '-alias', 'upload', '-storepass:env', 'LATER_GENERATED_PASSWORD', '-file', str(directory / 'upload-certificate.pem')], env=environment, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    (directory / 'key.properties').write_text(f'storeFile={store}\nstorePassword={password}\nkeyAlias=upload\nkeyPassword={password}\n')
    for item in directory.iterdir(): item.chmod(0o600)
except Exception:
    raise SystemExit('Key generation failed; inspect private directory before retrying. No material overwritten.')
print(f'Private upload key and properties created in {directory}; credentials were not printed.')
