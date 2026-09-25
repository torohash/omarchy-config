---
name: turso
description: Turso CLI (libSQL / Turso Cloud の操作) を mise で入れる。turso コマンドを導入・確認するときに使う。
metadata:
  privilege: user
  depends: none
---

# Turso CLI

`mise use -g turso` で入れる (Omarchy が CLI を入れるのと同じ mise の経路。sudo 不要)。
理由と比較した候補は [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
mise ls --global turso 2>/dev/null | grep -q turso && command -v turso >/dev/null && echo "turso: ok"
```

## 実行

```bash
mise use -g turso        # ~/.config/mise/config.toml に turso = "latest" が加わる
```

## ユーザーに頼む操作

Turso を使い始めるときに、ブラウザで GitHub 認証してもらう (セットアップ中は不要)。

```bash
turso auth login         # ヘッドレスなら turso auth login --headless
```

## 検証

```bash
turso --version                   # => turso version v1.x.x
command -v turso                  # => /home/<user>/.local/share/mise/shims/turso
turso auth whoami                 # => ユーザー名 (ログイン後)
```

## 元に戻す

```bash
mise unuse -g turso
rm -rf ~/.config/turso            # 認証情報も消す場合
```
