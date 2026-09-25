#!/usr/bin/env python3
"""Register GitHub's Ed25519 SSH host key in ~/.ssh/known_hosts after verifying it.

The key comes from the official HTTPS API (https://api.github.com/meta, TLS-verified)
and its SHA256 fingerprint is checked against the fingerprint the API publishes.
Unverified ssh-keyscan output is never trusted. Idempotent: does nothing when
known_hosts already has a github.com entry.
"""
import base64
import hashlib
import json
import os
import shutil
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

ssh_dir = Path.home() / '.ssh'
known_hosts = ssh_dir / 'known_hosts'

if known_hosts.is_symlink():
    sys.exit(f'{known_hosts} is a symlink; stopping.')

if known_hosts.exists():
    found = subprocess.run(['ssh-keygen', '-F', 'github.com', '-f', str(known_hosts)],
                           capture_output=True, text=True)
    if found.returncode == 0:
        print('GitHub host key already registered; nothing to do.')
        sys.exit(0)

with urllib.request.urlopen('https://api.github.com/meta', timeout=30) as response:
    meta = json.load(response)

keys = [key for key in meta['ssh_keys'] if key.startswith('ssh-ed25519 ')]
if len(keys) != 1:
    sys.exit('Unexpected GitHub Ed25519 key count; stopping.')
key = keys[0]
digest = hashlib.sha256(base64.b64decode(key.split()[1])).digest()
fingerprint = 'SHA256:' + base64.b64encode(digest).decode().rstrip('=')
expected = 'SHA256:' + meta['ssh_key_fingerprints']['SHA256_ED25519'].removeprefix('SHA256:')
if fingerprint != expected:
    sys.exit('GitHub fingerprint mismatch; stopping.')

ssh_dir.mkdir(mode=0o700, exist_ok=True)
if known_hosts.exists():
    backups = Path.home() / '.local/state/omarchy-config/backups'
    backups.mkdir(parents=True, exist_ok=True)
    shutil.copy2(known_hosts, backups / f'known_hosts.{int(time.time())}')

fd = os.open(known_hosts, os.O_WRONLY | os.O_CREAT | os.O_APPEND | os.O_NOFOLLOW, 0o600)
with os.fdopen(fd, 'a') as file:
    file.write('github.com ' + key + '\n')
print('Registered GitHub Ed25519 host key:', fingerprint)
