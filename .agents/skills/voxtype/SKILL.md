---
name: voxtype
description: Voxtype (Omarchy の音声入力。F9 を押している間だけ録音してカーソル位置に入力) を入れ、日本語で使えるようにする (多言語モデル small・language ja・VAD・Vulkan)。音声入力を導入するとき、話した日本語が英語で書き起こされるときに使う。
metadata:
  privilege: sudo
  depends: none
---

# Voxtype (音声入力) の日本語化

Omarchy の既定は英語専用 (`base.en` + `language = "en"`) で、日本語で話すと意味不明な英語になる。
モデルと言語の両方を変え、無音で出るでたらめを防ぐ VAD を有効にする。理由とモデルの比較は [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
pacman -Q voxtype-bin wtype >/dev/null \
  && [ "$(voxtype config get whisper.model)" = small ] \
  && [ "$(voxtype config get whisper.language)" = ja ] \
  && [ "$(voxtype config get vad.enabled)" = true ] \
  && systemctl --user is-active --quiet voxtype \
  && echo "voxtype: ok"
```

## 特権で行う操作

パッケージを入れ、Vulkan が使えれば GPU のバックエンドにする (`omarchy voxtype install` の sudo 部分)。

```bash
omarchy pkg add wtype voxtype-bin
if omarchy-hw-vulkan; then sudo voxtype setup gpu --enable || true; fi
```

## 実行

```bash
# 既定の設定 (無ければ Omarchy のものをコピー)
mkdir -p ~/.config/voxtype
[ -f ~/.config/voxtype/config.toml ] || cp "${OMARCHY_PATH:-/usr/share/omarchy}/default/voxtype/config.toml" ~/.config/voxtype/

# 多言語モデル (466MB) に切り替え、日本語にする
voxtype setup --download --model small --activate
voxtype config set whisper.language ja

# 無音区間のでたらめ対策 (VAD は既定で無効)
voxtype setup vad
voxtype config set vad.enabled true
voxtype config set vad.backend whisper

# 常駐と Omarchy への組み込み
voxtype setup systemd
hyprctl reload >/dev/null
omarchy restart shell
systemctl --user restart voxtype
```

## 検証

```bash
voxtype setup check              # => All checks passed (input グループの警告は無視してよい)
voxtype setup gpu --status       # => Active backend: GPU (Vulkan)  (Vulkan がある場合)

# 喋らずに試す: Wikimedia Commons の日本語音声
curl -sL "https://upload.wikimedia.org/wikipedia/commons/d/d2/Ja-Densha_2.oga" -o /tmp/voxtype-test.ogg
ffmpeg -y -loglevel error -i /tmp/voxtype-test.ogg -ar 16000 -ac 1 /tmp/voxtype-test.wav
voxtype transcribe /tmp/voxtype-test.wav     # => 電車
```

操作: **F9 を押している間だけ録音** / `Super+Ctrl+X` で録音のトグル。

## 元に戻す

```bash
omarchy voxtype remove
```
