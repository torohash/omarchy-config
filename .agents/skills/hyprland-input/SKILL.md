---
name: hyprland-input
description: Hyprland の入力設定を上書きし、キーボード配列を US、タッチパッドを自然スクロールにする。キーボード配列・タッチパッドのスクロール方向を設定・確認するとき、omarchy refresh hyprland で戻ったときに使う。
metadata:
  privilege: none
  depends: none
---

# キーボード配列とタッチパッド

`~/.config/hypr/input.lua` の末尾に上書きを足す (Omarchy 既定の後に読まれ、指定したキーだけ上書きされる)。
理由と Omarchy 既定の仕組みは [reference.md](reference.md)。

| 項目 | Omarchy 既定 | 設定値 |
|------|-------------|--------|
| `kb_layout` | `/etc/vconsole.conf` の `XKBLAYOUT` (JIS 機なら `jp`) | `us` |
| `touchpad.natural_scroll` | `false` | `true` |

**物理キーボードが JIS なら `kb_layout` は変えない** (印字と入力がずれる)。ユーザーに確認する。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
[ "$(hyprctl getoption input:kb_layout -j | jq -r .str)" = us ] \
  && hyprctl getoption input:touchpad:natural_scroll | grep -q 'bool: true' \
  && echo "hyprland-input: ok"
```

## 実行

1. 退避してから、`~/.config/hypr/input.lua` の末尾に追記する。

   ```bash
   mkdir -p ~/.local/state/omarchy-config/backups
   cp ~/.config/hypr/input.lua ~/.local/state/omarchy-config/backups/hypr-input.lua.$(date +%s)
   cat ~/dev/config/.agents/skills/hyprland-input/files/input-overrides.lua >> ~/.config/hypr/input.lua
   ```

2. 反映して、エラーが無いことを確かめる。

   ```bash
   hyprctl reload            # => ok
   hyprctl configerrors      # => 空
   ```

## 検証

```bash
hyprctl getoption input:kb_layout              # => str: us
hyprctl getoption input:touchpad:natural_scroll  # => bool: true
hyprctl configerrors                           # => 空
```

## 元に戻す

`~/.config/hypr/input.lua` から追記したブロックを消して `hyprctl reload`。
すべての Hyprland 設定を既定に戻すなら `omarchy refresh hyprland`。
