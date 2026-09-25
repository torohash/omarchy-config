# Bitwarden — 理由・Omarchy との連携・ハマりどころ

手順は [SKILL.md](SKILL.md)。

## 入れるもの

| パッケージ | 中身 |
|-----------|------|
| `bitwarden` (`extra`) | デスクトップアプリ (Electron)。コマンド名は `bitwarden-desktop` |
| `bitwarden-cli` (`extra`) | `bw`。`nodejs-lts-jod` に依存 |

Omarchy のメニュー (Install → Bitwarden) と同じもの
(`omarchy install and launch Bitwarden 'bitwarden bitwarden-cli' bitwarden`)。

## データの場所

| パス | 中身 |
|------|------|
| `~/.config/Bitwarden/` | デスクトップアプリの金庫キャッシュ (`data.json`) ほか |
| `~/.config/Bitwarden CLI/` | `bw` の設定。初回実行時に自動で作られる (名前に空白あり) |

**`data.json` は金庫そのもの。リポジトリには絶対にコピーしない。**

## Omarchy 側の既存の連携 (設定不要)

- ウィンドウルール (`/usr/share/omarchy/default/hypr/apps/bitwarden.lua`): 常にフローティング、画面共有に映らない。
  Chromium の Bitwarden 拡張のポップアップ用のルールもある。
- Electron は Wayland ネイティブ (`ELECTRON_OZONE_PLATFORM_HINT=wayland`)。

## Passwords キーの差し替え

Omarchy 既定は `o.bind("SUPER + SHIFT + SLASH", "Passwords", { omarchy = "1password" })`。
1Password が無いと、押したときにインストーラが開く。`hl.unbind` してから `o.bind` し直す。

- `focus = "^Bitwarden$"`: `omarchy-launch-or-focus` がウィンドウクラスの完全一致に使う。
  `^` `$` が無いとブラウザの「Bitwarden」タブを掴むことがある。既存の窓があればフォーカスだけする。

## ハマりどころ

1. **スクリーンショットで真っ黒に写る**: `no_screen_share = true` の仕様。バグではない。
   生きているかはレンダラプロセスで確かめる:
   ```bash
   for d in /proc/[0-9]*; do tr '\0' ' ' < $d/cmdline 2>/dev/null; echo; done | grep -c -- "--type=renderer"   # => 1 以上
   ```
2. **表示倍率が高いと窓が大きく出ることがある**: Omarchy は 1Password には `--force-device-scale-factor=1` を当てているが、
   Bitwarden には無い。気になるなら `bitwarden-desktop --force-device-scale-factor=1` で起動する。
3. `bw` の初回実行で `~/.config/Bitwarden CLI/` が作られる (未ログインの空の `data.json`)。
4. スクリプトから `bw` を使うにはセッションが要る (`export BW_SESSION=$(bw unlock --raw)`)。
   `bw login` / `bw unlock` は対話前提なので、エージェントの自動化には向かない。
5. `hyprctl keyword` は Lua 設定では使えない (`can't work with non-legacy parsers`)。動的に試すなら `hyprctl eval`。
