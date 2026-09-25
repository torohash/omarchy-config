# Chrome — 理由・候補

手順は [SKILL.md](SKILL.md)。

## `omarchy install browser chrome` が入れるもの

- `google-chrome` (AUR)
- `/etc/opt/chrome/policies/managed` (Omarchy のテーマ色 `color.json` の受け皿)
- `~/.config/chrome-flags.conf` (`--ozone-platform=wayland` / `--password-store=gnome-libsecret` / 拡張の `--load-extension`)
- Copy URL / yt-dlp の native messaging host (`~/.config/google-chrome/NativeMessagingHosts/`)

## Chrome にする理由

Google アカウントとの連携・同期が標準で使える。Omarchy のテーマ連携・拡張・Web アプリも使える (Chromium 系)。

## 候補 (`omarchy install browser <name>`)

| 候補 | こんなとき | Omarchy のテーマ / 拡張 / Web アプリ |
|------|-----------|-------------------------------------|
| **Chrome** | Google アカウント連携 | ◯ |
| Chromium | Omarchy のベース。追加インストール不要 | ◯ |
| Edge | Edge 固有の機能 | ◯ |
| Brave / Brave Origin | 広告ブロック・privacy 優先 | ◯ |
| Firefox / Zen | Gecko を使いたい | ✗ |

Web アプリ (`omarchy-launch-webapp`) は Chromium 系でしか開かない。Firefox 系を既定にしても
Web アプリは Chromium のままなので、**`chromium` は残す**。

## ハマりどころ

- AUR なのでエージェントの bash からは入れられない (sudo に TTY が要る)。
  メインの手順書がフローティング端末にまとめて実行する。
