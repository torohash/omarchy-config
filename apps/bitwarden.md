# Bitwarden — パスワードマネージャ

デスクトップアプリ (`bitwarden`) + CLI (`bw` = `bitwarden-cli`)。
**1Password ではなく Bitwarden を採用**している(Omarchy の既定は 1Password 前提なので、
「Passwords」キーの行き先などが Bitwarden を指していない。後述)。

## 導入手順

Omarchy には**公式の導線**が用意されている (`omarchy-menu.jsonc` の
`install.service.bitwarden`)ので、それが一番素直:

```bash
# メニュー: Omarchy menu → Install → Bitwarden
# CLI で同じもの:
omarchy install and launch Bitwarden 'bitwarden bitwarden-cli' bitwarden

# 手で入れるなら (これでも同じ結果)
omarchy pkg add bitwarden bitwarden-cli
# 端末からパスワードを入れられない場合:
#   pkexec pacman -S --noconfirm --needed bitwarden bitwarden-cli
```

`omarchy-install-and-launch` はフローティング端末で
`omarchy-pkg-add bitwarden bitwarden-cli` を走らせ、終わったら `gtk-launch bitwarden` する。

**パッケージは両方とも `extra`(公式リポジトリ)**。AUR / `yay` は不要だった。

依存として入るもの:

| パッケージ | 用途 |
|-----------|------|
| `electron39` | デスクトップアプリのランタイム |
| `libnotify` / `org.freedesktop.secrets` | 通知 / シークレットサービス連携 |
| `nodejs-lts-jod`, `argon2`, `semver` | `bitwarden-cli` (bw) |

## 実際の状態 (2026-09-25 時点)

```bash
$ pacman -Q bitwarden bitwarden-cli
bitwarden 2026.3.1-2
bitwarden-cli 2026.2.0-1
```

`/var/log/pacman.log`:

```
[2026-09-24T22:30:04+0900] [PACMAN] Running 'pacman -S --noconfirm --needed bitwarden bitwarden-cli'
[2026-09-24T22:30:27+0900] [ALPM] installed bitwarden (2026.3.1-2)
[2026-09-24T22:30:27+0900] [ALPM] installed bitwarden-cli (2026.2.0-1)
```

## 設定・データの場所

| パス | 中身 |
|------|------|
| `~/.config/Bitwarden/` | デスクトップアプリの金庫キャッシュ (`data.json`)、`app.log` ほか Electron のデータ |
| `~/.config/Bitwarden CLI/` | `bw` の設定 (`data.json`)。**初回実行時に自動で作られる**(名前のとおり空白入り) |
| `~/.config/autostart/` | 「Start automatically」をオンにすると `bitwarden.desktop` が入る(今は無し) |

> **`data.json` は金庫そのもの。`assets/` や `backups/` に絶対コピーしない。**
> このマシンの Bitwarden はアカウントをログイン済みで、端末側にのみ置く。

## Omarchy 側の既存連携 (ユーザー設定は不要)

- **ウィンドウルール** `/usr/share/omarchy/default/hypr/apps/bitwarden.lua`:

  ```lua
  o.window("^(Bitwarden)$", { no_screen_share = true, tag = "+floating-window" })
  o.window("chrome-nngceckbapebfimnlniiiahkandclblb-Default", {...})  -- ブラウザ拡張のポップアップ
  ```

  → Bitwarden は**常にフローティング**、かつ**画面共有に映らない**。
  2つ目のクラスは Chromium の Bitwarden 拡張のポップアップ用。
- **Electron は Wayland ネイティブ**。`default/hypr/envs.lua` が
  `ELECTRON_OZONE_PLATFORM_HINT=wayland` / `OZONE_PLATFORM=wayland` を設定している。
- ランチャーは `.desktop` (`Name=Bitwarden`, `Exec=bitwarden-desktop %u`,
  `StartupWMClass=Bitwarden`) 経由で自動的に出る。`omarchy` コマンドは無い。

## 検証コマンド (実際の結果)

```bash
pacman -Q bitwarden bitwarden-cli          # => bitwarden 2026.3.1-2 / bitwarden-cli 2026.2.0-1
bw --version                               # => 2026.2.0
gtk-launch bitwarden                       # GUI 起動 → ログイン
hyprctl clients -j | jq '.[] | select(.class | test("Bitwarden"))'
                                           # => floating で出る (no_screen_share は hyprctl に出ない)
omarchy-pkg-present bitwarden              # => 0 (メニューの Install 項目が消える)
```

## ハマりどころ

1. **`SUPER + SHIFT + SLASH` (Passwords) は 1Password を指したまま。**
   `/usr/share/omarchy/default/hypr/bindings/applications.lua`:

   ```lua
   o.bind("SUPER + SHIFT + SLASH", "Passwords", { omarchy = "1password" })
   ```

   1Password 未導入なので、押すと**インストーラ(フローティング端末)が開く**。
   Bitwarden に向けるなら `~/.config/hypr/bindings.lua` で

   ```lua
   hl.unbind("SUPER + SHIFT + SLASH")            -- 既定は 1Password
   o.bind("SUPER + SHIFT + SLASH", "Passwords", { launch = "bitwarden", focus = "^Bitwarden$" })
   ```

   (未実施。やるなら `hyprctl reload` + `hyprctl configerrors` で検証)
2. **Electron アプリはスケーリングで巨大になりやすい。** Omarchy 自身が 1Password 用に
   `--force-device-scale-factor=1` を当てている (`/usr/share/omarchy/bin/omarchy-launch-1password`)。
   Bitwarden には対策が無いので、**表示倍率を上げているときは窓が大きく出る可能性**がある。
   気になる場合は `bitwarden-desktop --force-device-scale-factor=1` で起動するか、
   `~/.local/share/applications/bitwarden.desktop` を作って `Exec` に足す(未実施)。
   なお倍率は `~/.config/hypr/monitors.lua` の `omarchy_monitor_scale`(現在 1.8)。
   → [display-scale.md](display-scale.md)
3. `bw --version` 等の**初回実行で `~/.config/Bitwarden CLI/` が勝手に作られる**
   (未ログインの空 `data.json` ができる)。
4. ウィンドウクラスは `Bitwarden`(`.desktop` の `StartupWMClass` と一致)。
   ウィンドウルールを自分で書くときはこの文字列に合わせる。
5. CLI でスクリプトから使うときはセッションが要る:
   `export BW_SESSION=$(bw unlock --raw)`。マスターパスワードはファイルに残さない。
6. `bw login` / `bw unlock` は対話入力が前提。エージェント的な自動化には向かない。

## 撤去

```bash
sudo pacman -Rns bitwarden bitwarden-cli
rm -rf ~/.config/Bitwarden ~/.config/"Bitwarden CLI"
```

(金庫が消えるので注意。同期していればサーバー側に残る)

## 参考

- [bitwarden.com](https://bitwarden.com/)
- 既定のウィンドウルール: `/usr/share/omarchy/default/hypr/apps/bitwarden.lua` (参照のみ)
- メニュー定義: `/usr/share/omarchy/default/omarchy/omarchy-menu.jsonc` の `install.service.bitwarden`
