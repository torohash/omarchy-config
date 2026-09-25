# Discord — 理由・Omarchy との連携・ハマりどころ

手順は [SKILL.md](SKILL.md)。

## 入れ方

`/usr/bin/discord` は Arch のブートストラッパで、初回起動時に Discord の配布サーバから本体を
`~/.config/discord/` (約 500MB) に落として実行する。パッケージを消してもこのディレクトリは残る。

トレイ (バー) にアイコンを出したい場合は任意で `omarchy pkg add libappindicator-gtk3`。

## Omarchy 側の既存の連携

- **Web アプリ版**: `~/.local/share/applications/Discord.desktop` (`omarchy-launch-webapp https://discord.com/channels/@me`)。
  クライアントを入れないならこれで足りる。
- `omarchy launch discord community`: ネイティブがあればアプリで、無ければブラウザで開く。
- `discord://` リンクは `discord.desktop` が受ける。Electron は Wayland ネイティブ。ウィンドウクラスは `discord`。
- 画面共有は `xdg-desktop-portal-hyprland` 経由。`no_screen_share` の窓 (Bitwarden 等) は共有しても真っ黒。

## ハマりどころ

1. **ランチャーに Discord が 2 つ並ぶ**: Web アプリ版と重複する。`omarchy webapp remove Discord` で片方にする。
   `omarchy install preinstalls` を実行すると Web アプリ版が復活することがある。
2. **初回起動にネットが必要**。オフラインだと Updater が失敗する。
3. **`discord-flags.conf` は効かない**。起動フラグは環境変数で渡す。
4. **MFA がパスキー / セキュリティキーだとログインできない** ("An error occurred. Please try again.")。
   Linux の Chromium / Electron にはプラットフォーム認証器が無い
   (`PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable()` が `false`、
   ポータルに WebAuthn のインターフェースが無い、Discord は libfido2 をリンクしていない)。
   回避策:
   - ダイアログの **Verify with something else** で TOTP / バックアップコード
   - **QR コードログイン** (スマホの Discord で読む)
   - ブラウザからログインし、TOTP を第二の手段として登録しておく
   - ハードウェアキーなら `omarchy pkg add libfido2` + udev ルール
5. 画面共有や音声に問題があれば、Wayland 対応のサードパーティクライアント (Vesktop など) も選択肢。

## 参考

- [How Discord Modernized MFA with WebAuthn](https://discord.com/blog/how-discord-modernized-mfa-with-webauthn)
- [discord-api-docs#7004](https://github.com/discord/discord-api-docs/issues/7004)
