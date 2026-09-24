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

## 設計思想 (なぜ Chromium を既定にしたのか)

Omarchy は自らを **「omakase(おまかせ)」の opinionated ディストロ**と呼ぶ。
公式サイトの言葉:

> Oma is for omakase, chef's choice: **we pick the tools and tune the details**, so you can get
> straight to work. But this is your computer. You're free to change everything.

つまり **「全ブラウザを平等に扱う」思想ではなく、「一貫した体験になる1つを選んで細部まで調える」**
思想。この選択を駆動しているのが [Omarchy Doctrine](/doctrine/) の次の3原則:

| 原則 | ブラウザ選定への効き方 |
|------|------------------------|
| **Beauty is truth** (美は真実。「色が調和していること」を設計目標にする) | ブラウザは画面で最も大きい面なので、**ライブテーマ**が必須。Chromium 系は policy でテーマ色を当てられる唯一の系統。DHH は upstream に機能が無かった時期に **Chromium を micro-fork してまで**ライブテーマを実現した (= 譲れない目標) |
| **Command is service** (委員会ではなく benevolent dictatorship が決める) | 「全員が好きなものを選べる」ことを目指さない。既定を決めて徹底するのが Omarchy の流儀 |
| **Own the machine** (tollbooth も gatekeeper もなし) | 入れるのは **plain open-source Chromium**(Google Chrome ではない)。Google アカウント連携は既定 OFF で、必要なら opt-in (`Install > Service > Chromium Account`) |

その他の構造的な理由 (前節の表と重なる):

- **Web アプリ第一級**: アプリの実体は `--app=` のフレームレス SSB ウィンドウ。
  Chromium 系だけがこれを標準で持つ (Firefox/Zen に相当機能がない)。
- **OS 連携**: Copy URL / Download Video (yt-dlp) は **native messaging host** で
  OS のクリップボード履歴・OSD に繋がる。これも Chromium 系のみ。

### 思想としての線引き: 既定は選ぶが、逃げ道は保証する

Manual は Firefox/Zen について「**拡張なし・テーマなし。そこは自分でやる領域**」と
明言する(隠さない)。一方で乗り換え手段は用意されている:

- `Install > Browser` で Chrome/Edge/Brave/Brave Origin/Firefox/Zen を入れ、
  ポリシーディレクトリを整え、テーマを当てる
- `omarchy default browser <name>` は **XDG ハンドラごと**差し替えるので、
  ホットキーだけでなくチャットアプリからのリンクも含めて全部が従う
- Chromium はベースに残る (Web アプリのエンジンなので `Remove > Browser` にも出ない)

要するに **「opinionated default + 完全な自由、ただし逸脱コストは明示」** という設計。

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
- [Omarchy Doctrine](https://omarchy.org/doctrine/) (設計思想 10 原則)
- [Manual: Browsers](https://omarchy.org/manual/browsers/) / [Manual: Web Apps](https://omarchy.org/manual/web-apps/)
- [Omarchy micro-forks Chromium](https://world.hey.com/dhh/omarchy-micro-forks-chromium-1287486d) (ライブテーマのための fork)
