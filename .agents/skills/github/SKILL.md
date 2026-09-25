---
name: github
description: GitHub を使えるようにする。gh の認証 (SSH 鍵の生成・登録を含む) をユーザーに案内し、GitHub の SSH ホスト鍵を公式 API で検証してから known_hosts に登録する。git push で Host key verification failed になるとき、GitHub の認証をセットアップするときに使う。
metadata:
  privilege: user
  depends: none
---

# GitHub (gh 認証と SSH ホスト鍵)

`gh` は Omarchy が mise で最初から入れている。`gh auth login` はブラウザ認証があるのでユーザーに頼む。
SSH remote (`git@github.com:...`) で push するには、GitHub のホスト鍵が `~/.ssh/known_hosts` に要る
(無いと非対話の接続が `Host key verification failed` になる)。理由とハマりどころは [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
gh auth status >/dev/null 2>&1 \
  && ssh-keygen -F github.com -f ~/.ssh/known_hosts >/dev/null \
  && echo "github: ok"
```

## ユーザーに頼む操作

`gh auth status` が失敗するときだけ。端末で次を実行してもらう。

```bash
gh auth login
```

選択肢は **GitHub.com → SSH → 新しい SSH 鍵を生成して GitHub に登録 (既存の鍵があればそれを選ぶ) → ブラウザでログイン**。
鍵ペアの生成と GitHub アカウントへの公開鍵の登録は、この操作で済む。

## 実行

GitHub のホスト鍵を検証して登録する (既に登録されていれば何もしない)。

```bash
python3 ~/dev/config/.agents/skills/github/files/register-github-hostkey.py
# => Registered GitHub Ed25519 host key: SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU
#    (登録済みなら) GitHub host key already registered; nothing to do.
```

## 検証

```bash
gh auth status                                          # => ✓ Logged in to github.com account <user>
                                                        #    - Git operations protocol: ssh
ssh -T -o BatchMode=yes -o ConnectTimeout=15 git@github.com
# => Hi <user>! You've successfully authenticated, but GitHub does not provide shell access.
#    (シェルを提供しないので、成功でも終了コードは 1)
stat -c '%a' ~/.ssh/known_hosts                         # => 600
```

## 元に戻す

```bash
ssh-keygen -R github.com -f ~/.ssh/known_hosts          # GitHub のホスト鍵だけ消す (ほかの行と鍵ペアは残す)
gh auth logout
```
