# GitHub — SSH 接続とホスト鍵の初回登録

Git の SSH remote (`git@github.com:...`) を使うため、GitHub の**公開ホスト鍵**を
`~/.ssh/known_hosts` に登録する。ホスト鍵は「接続先が GitHub であること」を確認する鍵で、
ユーザーの秘密鍵 (`~/.ssh/id_ed25519` 等) とは別物。

## 前提

- `ssh` / `python3` / `gh` を使えること。`gh` の導入・認証は
  [新規ホスト手順の 8](../setup/new-host.md#8-cli-ツール-mise-でグローバル) を参照。
- ユーザーの SSH 公開鍵を GitHub アカウントに登録すること。
  この手順は鍵ペアの生成やアカウントへの鍵登録は行わない。
- `gh auth login` による HTTPS 認証と、SSH のホスト鍵検証・ユーザー認証は独立している。

## 導入手順

### `known_hosts` がない新規環境

GitHub 公式の **HTTPS API** から Ed25519 公開ホスト鍵を取得し、API が示す指紋と
鍵から計算した指紋を照合する。信頼の根拠は HTTPS の証明書検証であり、
未検証の `ssh-keyscan` 出力をそのまま信用する方法は使わない。

```bash
python3 - <<'PY'
import base64
import hashlib
import json
import os
from pathlib import Path
import subprocess

meta = json.loads(subprocess.check_output(['gh', 'api', 'meta'], text=True, timeout=30))
keys = [key for key in meta['ssh_keys'] if key.startswith('ssh-ed25519 ')]
if len(keys) != 1:
    raise SystemExit('Unexpected GitHub Ed25519 key count; stopping.')
key = keys[0]
fingerprint = 'SHA256:' + base64.b64encode(hashlib.sha256(base64.b64decode(key.split()[1])).digest()).decode().rstrip('=')
expected = 'SHA256:' + meta['ssh_key_fingerprints']['SHA256_ED25519'].removeprefix('SHA256:')
if fingerprint != expected:
    raise SystemExit('GitHub fingerprint mismatch; stopping.')
ssh_dir = Path.home() / '.ssh'
ssh_dir.mkdir(mode=0o700, exist_ok=True)
path = ssh_dir / 'known_hosts'
# Exclusive creation: never overwrite an existing file or follow a symlink.
fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
with os.fdopen(fd, 'w') as file:
    file.write('github.com ' + key + '\n')
print('Registered GitHub Ed25519 host key:', fingerprint)
PY
```

期待値: `Registered GitHub Ed25519 host key: SHA256:...`。
`known_hosts` は権限 `600` で新規作成する。**既存ファイルがあれば上書きせず停止**するため、
その場合は次の手順を使う。ファイルを削除して作り直さない。

### `known_hosts` が既にある環境

既存ファイルを端末内でバックアップしてから、対話端末で `ssh -T git@github.com` を実行する。
初回確認が出たら、表示された鍵種別・指紋を
[GitHub 公式の指紋一覧](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)
と照合し、**一致するときだけ**承認する。
既存鍵との不一致警告が出た場合は、鍵を削除して回避せず原因を調べる。

## 検証と期待される出力

このリポジトリのディレクトリで実行する:

```bash
ssh -T -o BatchMode=yes -o ConnectTimeout=15 git@github.com
# => Hi <GitHubユーザー名>! You've successfully authenticated, but GitHub does not provide shell access.
# GitHub はシェルを提供しないため、認証成功でも終了コードは 1。

git ls-remote origin refs/heads/main
# => <コミットSHA> refs/heads/main（終了コード 0）

stat -c '%a %U %n' ~/.ssh/known_hosts
# => 600 <ローカルユーザー名> <ホームディレクトリ>/.ssh/known_hosts
```

## ハマりどころ

- **`known_hosts` がない + `BatchMode=yes`** では初回の信頼確認に答えられず、
  `Host key verification failed` になる。これだけで鍵の不一致とは判断できない。
- ホスト鍵検証はユーザー認証より先に行う。その段階の失敗を、秘密鍵や GitHub の
  リポジトリ権限の問題と混同しない。
- **`StrictHostKeyChecking=no` で回避しない**。検証を有効にしたまま公式鍵を登録する。
- 通常の SSH 接続では `UpdateHostKeys` により、認証後に別種のホスト鍵も追加される場合がある。
- **秘密鍵・`known_hosts`・そのバックアップを `assets/` や `backups/` にコピーしない**。
  `known_hosts` には他の接続先が含まれ得る。共有するのは手順だけにする。

## 撤去

GitHub のホスト鍵登録だけを削除する:

```bash
ssh-keygen -R github.com -f ~/.ssh/known_hosts
```

他の接続先やユーザーの鍵ペアは削除しない。生成される `.old` バックアップも端末内に置く。

## 参考

- [GitHub SSH ホスト鍵の指紋](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)
- [GitHub Meta API](https://api.github.com/meta)
- [GitHub SSH 接続のテスト](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection)
