---
name: zed
description: Zed エディタと Omarchy テーマ同期 (omazed) を入れ、端末で `zed` コマンドを使えるようにする。Zed を導入したい、`zed .` が command not found になるときに使う。
metadata:
  privilege: sudo
  depends: none
---

# Zed エディタ

Arch の `zed` は CLI を `/usr/bin/zeditor` という名前で入れる (ZFS の `zed` と衝突するため)。
`~/.local/bin/zed` に symlink を張って `zed .` を使えるようにする。理由とハマりどころは [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
pacman -Q zed omazed >/dev/null && [ "$(readlink ~/.local/bin/zed)" = /usr/bin/zeditor ] \
  && [ -x ~/.config/omarchy/hooks/theme-set.d/omazed ] && echo "zed: ok"
```

## 特権で行う操作

```bash
omarchy pkg add zed omazed
```

## 実行

```bash
omazed setup                                   # Omarchy のテーマを Zed に同期する hook を置く
mkdir -p ~/.local/bin
ln -sfn /usr/bin/zeditor ~/.local/bin/zed      # 端末の `zed` コマンド
```

## 検証

```bash
command -v zed                                 # => /home/<user>/.local/bin/zed
zed --version                                  # => Zed 1.x.x – /usr/lib/zed/zed-editor
ls ~/.config/omarchy/hooks/theme-set.d/omazed
```

## 元に戻す

```bash
rm ~/.local/bin/zed
omarchy pkg drop zed omazed
rm -rf ~/.config/zed ~/.local/share/omazed ~/.config/omarchy/hooks/theme-set.d/omazed
```
