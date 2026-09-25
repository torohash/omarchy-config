---
name: zed
description: Zed エディタと Omarchy テーマ同期 (omazed) を入れ、端末で `zed` コマンドを使えるようにし、フォントを HackGen Console NF にする。Zed を導入したい、`zed .` が command not found になるときに使う。
metadata:
  privilege: sudo
  depends: japanese-fonts
---

# Zed エディタ

Arch の `zed` は CLI を `/usr/bin/zeditor` という名前で入れる (ZFS の `zed` と衝突するため)。
`~/.local/bin/zed` に symlink を張って `zed .` を使えるようにする。理由とハマりどころは [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
pacman -Q zed omazed >/dev/null && [ "$(readlink ~/.local/bin/zed)" = /usr/bin/zeditor ] \
  && [ -x ~/.config/omarchy/hooks/theme-set.d/omazed ] \
  && jq -e '.buffer_font_family == "HackGen Console NF" and .ui_font_family == "HackGen Console NF"
            and .terminal.font_family == "HackGen Console NF"' ~/.config/zed/settings.json >/dev/null 2>&1 \
  && echo "zed: ok"
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

フォントを HackGen Console NF にする (エディタ本文・UI・Zed の中の端末)。`omarchy font set` は Zed を変えないので、
Zed の設定に直接書く。`settings.json` は Zed 自身も書き換えるので、キーを足すだけにする (skill `japanese-fonts` で HackGen を入れておく)。

```bash
f=~/.config/zed/settings.json
mkdir -p ~/.config/zed ~/.local/state/omarchy-config/backups
[ -f "$f" ] && cp "$f" ~/.local/state/omarchy-config/backups/zed-settings.json.$(date +%s) || echo '{}' > "$f"
tmp=$(mktemp "$f.XXXXXX")
jq '.buffer_font_family = "HackGen Console NF" | .ui_font_family = "HackGen Console NF"
    | .terminal = ((.terminal // {}) + {"font_family": "HackGen Console NF"})' "$f" > "$tmp" \
  && chmod 0600 "$tmp" && mv "$tmp" "$f"
```

Zed は設定ファイルを自動で読み直す。

## 検証

```bash
command -v zed                                 # => /home/<user>/.local/bin/zed
zed --version                                  # => Zed 1.x.x – /usr/lib/zed/zed-editor
ls ~/.config/omarchy/hooks/theme-set.d/omazed
jq -c '{buffer_font_family, ui_font_family, terminal: .terminal.font_family}' ~/.config/zed/settings.json
# => {"buffer_font_family":"HackGen Console NF","ui_font_family":"HackGen Console NF","terminal":"HackGen Console NF"}
```

## 元に戻す

```bash
rm ~/.local/bin/zed
omarchy pkg drop zed omazed
rm -rf ~/.config/zed ~/.local/share/omazed ~/.config/omarchy/hooks/theme-set.d/omazed
```
