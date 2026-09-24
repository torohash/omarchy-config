# Browser — 使っているブラウザ

**このホストの選択: Google Chrome(既定ブラウザも Chrome)。**
Omarchy のベースに含まれる `chromium` は残す(Web アプリのフォールバック / 保険)。

## 手順

```bash
# 導入 (AUR。sudo が要るので端末で実行)
omarchy install browser chrome
# エージェントの bash には TTY が無いので、代わりにこれを叩く (Omarchy メニューと同じ経路):
#   omarchy-launch-floating-terminal-with-presentation 'omarchy-install-browser chrome'

# 既定にする (XDG ハンドラごと切り替わる)
omarchy default browser chrome
```

`omarchy install browser chrome` が入れるもの:

- `google-chrome`(AUR)
- `/etc/opt/chrome/policies/managed`(テーマ色 `color.json` の受け皿)
- `~/.config/chrome-flags.conf`
  (`--ozone-platform=wayland` / `--password-store=gnome-libsecret` / 拡張の `--load-extension`)
- Copy URL / yt-dlp の native messaging host(`~/.config/google-chrome/NativeMessagingHosts/`)

確認:

```bash
omarchy default browser                    # => chrome
xdg-settings get default-web-browser       # => google-chrome.desktop
xdg-mime query default x-scheme-handler/https
```

## 候補と、選ぶときに効く違い

Omarchy が用意しているのは次の6つ(Install > Browser、または `omarchy install browser <name>`):

| 候補 | こんなとき | Omarchy のテーマ / 拡張 / Web アプリ* |
|------|-----------|-----------------------------------|
| **Chrome**(現在の選択) | Google アカウント連携・同期が標準で使える | ◯ |
| Chromium | Omarchy のベース。追加インストール不要 | ◯ |
| Edge | Edge 固有機能が要る | ◯ |
| Brave | 広告ブロック / privacy 優先 | ◯ |
| Brave Origin | Brave から crypto・rewards を外した版 | ◯ |
| Firefox | Gecko を使いたい | ✗ |
| Zen | Firefox ベースで見た目重視 | ✗ |

\* Web アプリ (`omarchy-launch-webapp`) は Chromium 系でしか開かない。
Firefox / Zen を既定にしても Web アプリは Chromium のままなので、**chromium は残す**。
テーマ色の連携と Omarchy 拡張(Copy URL / yt-dlp)も Chromium 系のみ。

## 変更 / 撤去

```bash
omarchy default browser              # 現在の既定を表示
omarchy default browser chromium     # 変更
omarchy remove browser chrome        # 撤去 (既定なら chromium に戻す処理込み)
```
