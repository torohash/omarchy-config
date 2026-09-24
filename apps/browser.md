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

## 設計思想 (なぜ Chromium を既定にしたのか) — ※再現には不要な補足

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

## 他の候補ブラウザ (Omarchy が実際に何をするか)

`omarchy install browser <name>` がやることを、そのまま表にする。
**他のホストで別ブラウザを選ぶときは、この表の「パッケージ」と「設定されるもの」が必要になる。**

| ブラウザ | パッケージ (入手元) | 設定されるもの | テーマ | 拡張 | Web アプリ |
|---------|------------------|--------------|------|------|-----------|
| **Chromium** (既定) | `chromium` (repo) | `/etc/chromium/policies/managed` + `~/.config/chromium-flags.conf` | ◯ | ◯ | ◯ |
| Chrome | `google-chrome` (**AUR**) | `/etc/opt/chrome/policies/managed` + `~/.config/chrome-flags.conf` | ◯ | ◯ | ◯ |
| Edge | `microsoft-edge-stable-bin` (**AUR**) | `/etc/opt/edge/policies/managed` + `~/.config/microsoft-edge-stable-flags.conf` | ◯ | ◯ | ◯ |
| Brave | `brave-bin` (**AUR**) | `/etc/brave/policies/managed` + `~/.config/brave-flags.conf` | ◯ | ◯ | ◯ |
| Brave Origin | `brave-origin-bin` (**AUR**) | 同上(policy は brave と共通) + `~/.config/brave-origin-flags.conf` | ◯ | ◯ | ◯ |
| Firefox | `firefox` (repo) | `/usr/lib/firefox/distribution/policies.json` + `~/.config/environment.d/omarchy-firefox-wayland.conf` | ✗ | ✗ | ✗ |
| Zen | `zen-browser-bin` (**AUR**) | `/opt/zen-browser/distribution/policies.json` + 同じ Wayland env | ✗ | ✗ | ✗ |

### Chromium 系に共通の処理 (`copy_chromium_flags`)

1. policy dir を用意する(root:root 0755。`browser-policy.sh` が親ディレクトリも含めて hardening)
2. `$OMARCHY_PATH/config/chromium-flags.conf` を **そのブラウザ用の名前にコピー**
   (`-flags.conf` の命名はブラウザごとに違う。Chromium は `chromium-flags.conf`、Chrome は
   `chrome-flags.conf`、Edge は `microsoft-edge-stable-flags.conf`、Brave は `brave-flags.conf`)
3. **Copy URL / yt-dlp の native messaging host をインストール**
   (`omarchy-install-chromium-copy-url` / `-ytdlp`。
   `~/.config/chromium`, `google-chrome`, `BraveSoftware/Brave-Browser`, `microsoft-edge` などの
   プロファイルディレクトリ全部に対して manifest を置く)
4. 現在のテーマ色を `color.json` として policy dir に書く (`omarchy-theme-set-browser`)

### Firefox / Zen の扱い (思想としての割り切り)

設定されるのは**既定値の調整と Wayland ネイティブ化だけ**:

- `/usr/share/omarchy/default/firefox/policies.json` を `distribution/` に配置。中身は
  `apz.overscroll.enabled` / `media.ffmpeg.vaapi.enabled` /
  `media.hardware-video-decoding.force-enabled` / `widget.disable-swipe-tracker` /
  `widget.wayland.fractional-scale.enabled` (= タッチパッド・HW デコード・fractional scale を有効化)
- `~/.config/environment.d/omarchy-firefox-wayland.conf` に `MOZ_ENABLE_WAYLAND=1`

**テーマは当たらない・拡張は入らない・Web アプリは Chromium のまま**(下表の注意 1)。
Manual にも「extensions は無し、themed でも無い。そこは自分でやる」と明記されている。

### 導入手順と切替

```bash
# 1. 入れる (AUR パッケージは omarchy-pkg-aur-add が入れる。sudo が要るので端末で実行)
omarchy install browser firefox

# 2. 既定にする (XDG ハンドラごと差し替わる)
omarchy default browser firefox

# 3. やめる
omarchy remove browser firefox      # flags ファイルと color.json も消す
```

`omarchy remove browser` は「既定がそれだったら chromium に戻す」処理も入っている。

### どれを選ぶか

| 望み | 選択 |
|------|------|
| Omarchy の体験(テーマ / Web アプリ / 拡張)をそのまま使いたい | **Chromium** のままでよい |
| Google 連携・Chrome 固有機能が欲しい | Chrome |
| 広告ブロック / privacy 優先 | Brave(Brave Origin は crypto・rewards を外したミニマル版) |
| Gecko / Firefox が好き | Firefox(テーマ・拡張・Web アプリは自分で。**chromium は残す**) |
| Firefox ベースで見た目も今風に | Zen(扱いは Firefox と同じ) |

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
