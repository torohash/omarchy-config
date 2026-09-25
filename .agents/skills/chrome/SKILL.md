---
name: chrome
description: Google Chrome を Omarchy 経由で入れて既定のブラウザにする (Omarchy 同梱の chromium は残す)。ブラウザを Chrome にしたい・既定ブラウザを確認したいときに使う。
metadata:
  privilege: sudo
  depends: none
---

# Google Chrome を既定のブラウザにする

Omarchy のインストーラーで Chrome (AUR `google-chrome`) を入れ、既定にする。
Web アプリは Chromium 系でしか開かないので、ベースの `chromium` は消さない。理由と候補は [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
pacman -Q google-chrome >/dev/null && [ "$(omarchy default browser)" = chrome ] && echo "chrome: ok"
```

## 特権で行う操作

`pacman -Q google-chrome` が失敗するときだけ行う。AUR からの導入と `/etc/opt/chrome/policies/managed` の作成で sudo を使う。

```bash
omarchy install browser chrome
```

## 実行

```bash
omarchy default browser chrome
```

## 検証

```bash
omarchy default browser                        # => chrome
xdg-settings get default-web-browser           # => google-chrome.desktop
ls ~/.config/chrome-flags.conf                 # Omarchy のインストーラーが置く
```

## 元に戻す

```bash
omarchy remove browser chrome      # 既定だった場合は chromium に戻す処理も含む
```
