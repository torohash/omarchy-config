# Browser — 既定ブラウザは Chromium (Omarchy のベースパッケージ)

`xdg-settings get default-web-browser` は `chromium.desktop`。
**これは Omarchy のベースパッケージとして chromium が入っているから**で、
ユーザーが選んだ結果ではない。

## なぜ Chromium なのか

| 理由 | 根拠 |
|------|------|
| **Omarchy のベースパッケージ** | `/usr/share/omarchy/install/omarchy-base.packages` に `chromium` がある(インストーラが入れる) |
| **Web アプリ機能が Chromium 前提** | `omarchy-launch-webapp` は既定ブラウザが Chromium 系(`google-chrome*`/`brave*`/`microsoft-edge*`/`opera*`/`vivaldi*`/`helium*`)**以外なら `chromium.desktop` に強制フォールバック**する。`--app=<url>` で PWA 風ウィンドウを開くため |
| **テーマ連携が Chromium 系のみ** | `omarchy-theme-set-browser` が現在のテーマのアクセント色を Chromium / Chrome / Edge / Brave にだけ書き込む |
| **拡張の native messaging host が Chromium 向け** | `~/.config/chromium-flags.conf`(Omarchy が用意)が `--load-extension` で copy-url / yt-dlp / whatsapp-slim を読み込む |
| **Wayland 向けフラグ済み** | 同 flags ファイルが `--ozone-platform=wayland` / `--password-store=gnome-libsecret` を渡す |

## `$BROWSER` の扱い

- 対話シェルでは `BROWSER=omarchy-launch-browser` が export されている
  (`/usr/share/omarchy/default/bash/envs`)。
- **セッション全体には export しない**のが Omarchy の方針
  (`default/uwsm/default` にその旨のコメント)。理由: セッション全体にすると
  `xdg-settings` が既定ブラウザを誤検出する。
- `omarchy-launch-browser` は `xdg-settings` から既定ブラウザを引いて起動し、
  `--private` を各ブラウザの privacy フラグに変換する。

## 変える

```bash
omarchy default browser            # 現在値 (chromium)
omarchy default browser firefox    # 変更
# 引数: chromium | chrome | brave | brave-origin | edge | firefox | zen
```

Omarchy menu → Setup → Default Browser からも同じ。

## 注意

1. **Web アプリは Chromium 系でしか開かない。** Firefox を既定にしても
   `omarchy-launch-webapp` は `chromium.desktop` を使う。→ **chromium は消さない**。
2. テーマ色の連携と `--load-extension` は Chromium 系のみ。
3. ブラウザを追加するときは Omarchy 経由:
   ```bash
   omarchy install browser chrome      # chrome|brave|brave-origin|edge|firefox|zen
   ```
4. 既定ブラウザを変えると `xdg-settings` の `https` / `text/html` /
   `default-web-browser` の3つが揃って変わる(`omarchy-default-browser` が実施)。

## 検証 (期待される出力)

```bash
xdg-settings get default-web-browser        # => chromium.desktop (既定)
xdg-mime query default x-scheme-handler/https
omarchy default browser                     # => chromium
echo "$BROWSER"                             # => omarchy-launch-browser (対話シェル)
cat ~/.config/chromium-flags.conf           # => ozone-platform=wayland 等
```

## 参考

- `/usr/share/omarchy/bin/omarchy-launch-webapp` (Chromium フォールバックの実装)
- `/usr/share/omarchy/bin/omarchy-default-browser` (既定ブラウザの切替)
- `/usr/share/omarchy/install/omarchy-base.packages` (chromium が入る根拠)
