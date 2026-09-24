# Bitwarden — パスワードマネージャ

デスクトップアプリ (`bitwarden`) + CLI (`bw` = `bitwarden-cli`)。
**1Password ではなく Bitwarden を採用**している(Omarchy の既定は 1Password 前提なので、
「Passwords」キー `SUPER + SHIFT + /` の行き先だけ Bitwarden に差し替えてある。→ ハマりどころ 2)。

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

# キーバインドが実行するコマンドそのもの (o.bind の { launch, focus } の展開形)
omarchy-launch-or-focus '^Bitwarden$' 'uwsm-app -- bitwarden-desktop'
hyprctl clients -j | jq '.[] | select(.class=="Bitwarden") | {floating, size, at}'
# => floating=true, size=[875,600] (論理px / 倍率 1.8 での普通のサイズ)
# 2回目以降は新窓を作らず既存を focus する (窓数が増えないことを確認済み)

# キー側
hyprctl configerrors                       # => 空
hyprctl binds -j | jq '.[] | select(.description=="Passwords")'
# => SUPER+SHIFT+SLASH のエントリが **1件だけ** (hl.unbind が効いている証拠)
                                           #   modmask=65 = SUPER(64) + SHIFT(1)
omarchy menu keybindings --print | grep SLASH   # => SUPER SHIFT + SLASH → Passwords
omarchy-pkg-present bitwarden              # => 0 (メニューの Install 項目が消える)
```

> **スクショで確かめようとすると真っ黒に見えるが正常**。下の「1. 画面共有除外」の仕様。
> 見た目の確認は実画面で行うこと。

## ハマりどころ

1. **スクリーンショットに映らない (grim で真っ黒)。** これはバグではなく、
   Omarchy 既定のウィンドウルール `no_screen_share = true` の仕様。Bitwarden の窓は
   `grim` や画面共有で**真っ黒な矩形**として写る。描画が死んでいるわけではない。
   本当に生きているかはレンダラプロセスを見る:

   ```bash
   for d in /proc/[0-9]*; do tr '\0' ' ' < $d/cmdline 2>/dev/null; echo; done \
     | grep -c -- "--type=renderer"       # => 1以上 (Bitwarden のレンダラが居る)
   ```

   A/B 確認済み: foot に `hyprctl eval 'o.window("^(foot)$", { no_screen_share = true })'`
   を当てると foot も真っ黒になり、`hyprctl reload` で戻ると再び写る。
   (`hyprctl keyword` はこのバージョンでは `can't work with non-legacy parsers` で不可。`eval` を使う。
   動的に当てたルールは `hyprctl reload` で消える)
2. **`SUPER + SHIFT + SLASH` (Passwords) は既定では 1Password を指している。**
   本機では `~/.config/hypr/bindings.lua` で **Bitwarden に差し替え済み** (2026-09-25):

   ```lua
   hl.unbind("SUPER + SHIFT + SLASH")   -- 既定: o.bind(..., { omarchy = "1password" })
   o.bind("SUPER + SHIFT + SLASH", "Passwords", { launch = "bitwarden-desktop", focus = "^Bitwarden$" })
   ```

   - **バイナリ名は `bitwarden-desktop`**。`bitwarden` というコマンドは無い (`.desktop` の Exec もこれ)。
     誤って `launch = "bitwarden"` と書くと起動しない。
   - `focus` は `omarchy-launch-or-focus` が `\b^Bitwarden$\b` に組み立てる。`^` `$` を付けると
     ウィンドウクラス `Bitwarden` の完全一致だけに当たる (付けないとブラウザの“Bitwarden”タブを掴む恐れ)。
   - 変更前は `backups/hypr-bindings.lua.before-bitwarden` に退避。
3. **Electron アプリはスケーリングで巨大になりやすい。** Omarchy 自身が 1Password 用に
   `--force-device-scale-factor=1` を当てている (`/usr/share/omarchy/bin/omarchy-launch-1password`)。
   Bitwarden には対策が無いが、**倍率 1.8 で起動しても論理サイズ 875x600 と普通の大きさ**で、
   破綻は見られなかった (ただし上記 1 の理由でスクショでは見えないので、見た目の最終判断は目視)。
   大きすぎると感じたら `bitwarden-desktop --force-device-scale-factor=1` で起動するか、
   `~/.local/share/applications/bitwarden.desktop` を作って `Exec` に足す(未実施)。
   倍率は `~/.config/hypr/monitors.lua` の `omarchy_monitor_scale`(現在 1.8)。
   → [display-scale.md](display-scale.md)
4. `bw --version` 等の**初回実行で `~/.config/Bitwarden CLI/` が勝手に作られる**
   (未ログインの空 `data.json` ができる)。
5. ウィンドウクラスは `Bitwarden`(`.desktop` の `StartupWMClass` と一致)。
   ウィンドウルールを自分で書くときはこの文字列に合わせる。
6. CLI でスクリプトから使うときはセッションが要る:
   `export BW_SESSION=$(bw unlock --raw)`。マスターパスワードはファイルに残さない。
7. `bw login` / `bw unlock` は対話入力が前提。エージェント的な自動化には向かない。

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
