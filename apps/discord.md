# Discord — チャット (公式クライアント)

公式の Discord デスクトップクライアントを入れる。**`extra` にあるので AUR は不要**。
Omarchy 側には Web アプリ版の導線 (`Discord.desktop`) も用意されているので、
クライアントを入れるかどうかは好みで決められる。

## 導入手順

```bash
# Omarchy 経由 (推奨)
omarchy pkg add discord
```

> 権限が要るので**端末で実行する**(エージェントが `pkexec pacman -S` で直接叩かない)。
> 入れる前に **Omarchy に Web アプリ版がないか**を必ず確認する(下の「ハマりどころ 1」)。

任意: **トレイ (バー) にアイコンを出したい場合**は `libappindicator-gtk3` も入れる
(パッケージの任意依存。Omarchy の `omarchy.tray` に出る):

```bash
omarchy pkg add libappindicator-gtk3
```

### 初回起動 (重要: 本体はここでダウンロードされる)

`/usr/bin/discord` は **Arch のブートストラッパ**で、本体はまだ入っていない。
初回起動時に Discord の配布サーバから本体を `~/.config/discord/` に落とし、
以後はそれを exec する。

```bash
discord          # 初回は更新ウィンドウ (Discord Updater) → 本体ウィンドウの順に出る
```

- **ネット接続が必須**。初回だけ数十秒かかる。
- ディスクを **約 500MB** 使う(`~/.config/discord/`)。`pacman -Rns discord` しても
  このディレクトリは残るので、撤去時は手で消す。
- 2回目以降は `discord` で即起動する(更新があるときだけ Updater が挟まる)。

## 設定・データの場所

| パス | 中身 |
|------|------|
| `~/.config/discord/` | **本体 (Electron) 一式** + 設定。初回起動で展開される |
| `~/.config/discord/settings.json` | Discord 側の設定 (更新スキップなど) |

## Omarchy 側の既存連携 (設定不要)

- **Web アプリ版**: `~/.local/share/applications/Discord.desktop` が最初からあり、
  `omarchy-launch-webapp https://discord.com/channels/@me` を呼ぶ。
  ネイティブを入れないならこちらをそのまま使える(インストール不要)。
- **`omarchy launch discord community`**: ネイティブの `discord` があればアプリで、
  無ければブラウザで Omarchy コミュニティを開く (`omarchy-launch-discord-community`)。
- **URL スキーム**: `discord.desktop` が `x-scheme-handler/discord` を登録するので、
  `discord://` リンクはアプリで開く。
- **Electron は Wayland ネイティブ**。`default/hypr/envs.lua` の
  `ELECTRON_OZONE_PLATFORM_HINT=wayland` / `OZONE_PLATFORM=wayland` に乗る。
  ウィンドウクラスは `discord`(`StartupWMClass=discord`)。
- ウィンドウルールは Omarchy に無い(= 通常のタイル窓として開く)。

## 画面共有

Omarchy は `xdg-desktop-portal-hyprland` + `xdg-desktop-portal-gtk` を入れており、
`~/.config/hypr/xdph.conf` に

```conf
screencopy {
    allow_token_by_default = true
    custom_picker_binary = hyprland-preview-share-picker
}
```

が設定されている。Discord の「画面を共有」はこのポータル経由で
ウィンドウ / モニタを選ぶ。**`no_screen_share` なウィンドウは選んでも真っ黒**になる
(→ [bitwarden.md](bitwarden.md) の 1 参照)。

## 検証 (期待される出力)

```bash
pacman -Q discord                       # => discord 1:1.0.156-1 など
discord                                 # ウィンドウが出る
hyprctl clients -j | jq '.[] | select(.class=="discord") | {xwayland, floating, size}'
# => xwayland=false (Wayland ネイティブ), floating=false (タイル), size は適当な値
```

## ハマりどころ

1. **ランチャーに "Discord" が2つ並ぶ。** Omarchy は Discord の **Web アプリ版**
   (`~/.local/share/applications/Discord.desktop`) を最初から持っているので、
   ネイティブを入れると同名のエントリが重複する。どちらか一方にする:

   ```bash
   omarchy webapp remove Discord      # Web アプリ版のランチャーを消す
   # 戻したいとき:
   #   omarchy webapp install Discord https://discord.com/channels/@me omarchy-discord
   ```

   (`omarchy install preinstalls` を実行すると Web アプリ側が復活することがある)
2. **`pacman -S discord` だけでは使えない。** 初回起動で本体 (約 500MB) を落とす。
   オフラインだと Updater が失敗する。
2. **撤去時に `~/.config/discord/` が残る**(パッケージ外のダウンロード物)。
3. **撤去時に `~/.config/discord/` が残る**(パッケージ外のダウンロード物)。
4. **`discord-flags.conf` は効かない。** このパッケージの `/usr/bin/discord` は
   フラグファイルを読まないラッパなので、起動フラグを足したいときは環境変数
   (`ELECTRON_OZONE_PLATFORM_HINT` など) で渡す。
5. 画面共有・音声がうまく動かない場合は、Wayland 対応をうたう
   サードパーティクライアント (Vesktop など、AUR) という選択肢もある。
   公式クライアントで足りない場合のみ検討する。
6. ウィンドウクラスは `discord`。ルールを書くときはこの文字列を使う。
7. **MFA がパスキー/セキュリティキーだとログインできない** ("An error occurred.
   Please try again.")。Discord の MFA ダイアログが WebAuthn (passkey/security key)
   を使うのに対し、**Linux の Chromium/Electron にはプラットフォーム認証器がない**
   (`navigator.credentials.create/get` が即失敗する)。
   Discord 公式ブログも「Electron に WebAuthn の明示的なサポートはない」と書いている。

   ローカルでの確認結果:

   - Chromium で (secure context で) 評価すると **プラットフォーム認証器は無い**:
     `PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable()` → `false`
     (確認方法: chromium を `--remote-debugging-port` 付きで起動し https ページで評価)
   - `busctl --user introspect org.freedesktop.portal.Desktop
     /org/freedesktop/portal/desktop | grep -i webauthn` → **インターフェースなし**
     (OS 側のパスキー提供元もない)
   - `ldd ~/.config/discord/app-*/Discord | grep fido` → **libfido2 はリンクしていない**
   - Discord のログ (`~/.config/discord/logs/`) には WebAuthn の失敗が**出ない**
     (ceremony の前で失敗するため)

   回避策:

   1. ダイアログの **"Verify with something else"** で TOTP (認証アプリ) か
      バックアップコードを使う
   2. **QR コードログイン**(スマホの Discord で読む)。モバイル側は WebAuthn が使える
   3. **ブラウザ (Chromium) からログイン**する。パスキーを Bitwarden / Chromium に
      入れている場合は、その拡張/プロファイル側でなら提示できる
   4. ブラウザ側で **TOTP を第二手段として登録**しておくと、アプリからも使える
   5. ハードウェアキーを使う場合は `libfido2` + udev ルールが必要
      (`omarchy pkg add libfido2`)。この場合はアプリ側の問題と切り分ける

   → 関連: [How Discord Modernized MFA with WebAuthn](https://discord.com/blog/how-discord-modernized-mfa-with-webauthn)、
   [discord-api-docs#7004](https://github.com/discord/discord-api-docs/issues/7004)

## 撤去

```bash
sudo pacman -Rns discord              # ラッパ本体を削除
rm -rf ~/.config/discord              # 初回DLした本体 (約 500MB) も消す
```

## 参考

- [discord.com](https://discord.com/)
- ラッパ実装: `/usr/bin/discord`(参照のみ。初回に本体を落として exec するだけのスクリプト)
- Web アプリ版: `~/.local/share/applications/Discord.desktop`
