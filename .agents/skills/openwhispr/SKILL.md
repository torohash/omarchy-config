---
name: openwhispr
description: OpenWhispr (音声入力と会議の議事録を取るアプリ。話者の区別つき) を AUR から入れ、Hyprland の Super+Shift+K (音声入力) と Super+Shift+M (議事録) から呼べるようにする。議事録を取りたい、OpenWhispr を導入・確認するときに使う。
metadata:
  privilege: sudo
  depends: none
---

# OpenWhispr (議事録・音声入力)

会議の議事録 (Zoom / Teams の自動検出、話者の区別、メモ) のために入れる。Voxtype は議事録を取れない。
Hyprland では OpenWhispr 自身のグローバルキー (GNOME のポータル頼み) が効かないことがあるので、Hyprland のキーから D-Bus で呼ぶ。
起動していなければ起動する。

| キー | 操作 (D-Bus のメソッド) |
|------|------------------------|
| `Super+Shift+K` | 音声入力の開始 / 停止 (`Toggle`) |
| `Super+Shift+M` | 議事録の開始 / 停止 (`ToggleMeeting`) |
理由と Voxtype との比較は [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
pacman -Q openwhispr-bin >/dev/null \
  && grep -q 'omarchy-config: openwhispr' ~/.config/hypr/bindings.lua \
  && echo "openwhispr: ok"
```

## 特権で行う操作

```bash
omarchy pkg aur add openwhispr-bin
```

## 実行

キーの割り当てが無ければ、退避してから `~/.config/hypr/bindings.lua` の末尾に追記する。

```bash
if ! grep -q 'omarchy-config: openwhispr' ~/.config/hypr/bindings.lua; then
  mkdir -p ~/.local/state/omarchy-config/backups
  cp ~/.config/hypr/bindings.lua ~/.local/state/omarchy-config/backups/hypr-bindings.lua.$(date +%s)
  cat ~/dev/config/.agents/skills/openwhispr/files/bindings-overrides.lua >> ~/.config/hypr/bindings.lua
fi
hyprctl reload            # => ok
hyprctl configerrors      # => 空
```

## ユーザーに頼む操作

OpenWhispr を起動して初期設定をしてもらう (モデルの選択・ダウンロード、マイクの許可)。サインインは任意。
OpenWhispr の設定にある自身のグローバルキーは使わない (Hyprland のキーと二重になる)。

## 検証

```bash
pacman -Q openwhispr-bin                                          # => openwhispr-bin 1.x.x
omarchy menu keybindings --print | grep '→ OpenWhispr'
# => SUPER SHIFT + K → OpenWhispr dictation
#    SUPER SHIFT + M → OpenWhispr meeting
```

## 元に戻す

`~/.config/hypr/bindings.lua` から追記したブロックを消して `hyprctl reload`。

```bash
omarchy pkg drop openwhispr-bin
```
