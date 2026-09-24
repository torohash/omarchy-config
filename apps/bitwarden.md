# Bitwarden — パスワードマネージャ

デスクトップアプリ (`bitwarden`) + CLI (`bw` = `bitwarden-cli`) を入れる。
**1Password ではなく Bitwarden を使う**ため、Omarchy 既定の「Passwords」キー
`SUPER + SHIFT + /` の行き先を Bitwarden に差し替える(→ ハマりどころ 2)。

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

**パッケージは両方とも `extra`(公式リポジトリ)**。AUR / `yay` は不要。

依存として入るもの:

| パッケージ | 用途 |
|-----------|------|
| `electron39` | デスクトップアプリのランタイム |
| `libnotify` / `org.freedesktop.secrets` | 通知 / シークレットサービス連携 |
| `nodejs-lts-jod`, `argon2`, `semver` | `bitwarden-cli` (bw) |

## 設定・データの場所

| パス | 中身 |
|------|------|
| `~/.config/Bitwarden/` | デスクトップアプリの金庫キャッシュ (`data.json`)、`app.log` ほか Electron のデータ |
| `~/.config/Bitwarden CLI/` | `bw` の設定 (`data.json`)。**初回実行時に自動で作られる**(名前のとおり空白入り) |
| `~/.config/autostart/` | アプリ側で「Start automatically」をオンにすると `bitwarden.desktop` が入る |

> **`data.json` は金庫そのもの。`assets/` や `backups/` に絶対コピーしない。**
> 端末側にしか置かない。

## Omarchy 側の既存連携 (設定不要)

- **ウィンドウルール** `/usr/share/omarchy/default/hypr/apps/bitwarden.lua`:

  ```lua
  o.window("^(Bitwarden)$", { no_screen_share = true, tag = "+floating-window" })
  o.window("chrome-nngceckbapebfimnlniiiahkandclblb-Default", {...})  -- ブラウザ拡張のポップアップ
  ```

  → Bitwarden は**常にフローティング**、かつ**画面共有に映らない**。
  2つ目のクラスは Chromium の Bitwarden 拡張のポップアップ用。
- **Electron は Wayland ネイティブ**。`default/hypr/envs.lua` が
  `ELECTRON_OZONE_PLATFORM_HINT=wayland` / `OZONE_PLATFORM=wayland` を設定する。
- ランチャーは `.desktop` (`Name=Bitwarden`, `Exec=bitwarden-desktop %u`,
  `StartupWMClass=Bitwarden`) 経由で自動的に出る。`omarchy` コマンドは無い。

## キーバインド (Passwords キーの差し替え)

`~/.config/hypr/bindings.lua` に追記する。Omarchy 既定は 1Password を指しており、
1Password 未導入だと押すとインストーラが開いてしまうため:

```lua
hl.unbind("SUPER + SHIFT + SLASH")   -- 既定: o.bind(..., { omarchy = "1password" })
o.bind("SUPER + SHIFT + SLASH", "Passwords", { launch = "bitwarden-desktop", focus = "^Bitwarden$" })
```

- **バイナリ名は `bitwarden-desktop`**。`bitwarden` というコマンドは存在しない
  (`.desktop` の `Exec` もこれ)。
- `focus` は `omarchy-launch-or-focus` が `\b^Bitwarden$\b` に組み立てる。
  `^` `$` を付けるとウィンドウクラス `Bitwarden` の完全一致だけに当たる
  (付けないとブラウザの “Bitwarden” タブを掴む恐れがある)。
- バインドの実体は `omarchy-launch-or-focus '^Bitwarden$' 'uwsm-app -- bitwarden-desktop'`。
  既存ウィンドウがあれば新窓を作らずフォーカスする。

## 検証

```bash
pacman -Q bitwarden bitwarden-cli          # => bitwarden 2026.x / bitwarden-cli 2026.x
bw --version                               # => 2026.x
omarchy-pkg-present bitwarden              # => 0 (メニューの Install 項目が消える)

# キーバインド (期待値)
hyprctl reload && hyprctl configerrors     # => 空
hyprctl binds -j | jq '.[] | select(.description=="Passwords")'
# => SUPER+SHIFT+SLASH のエントリが 1件だけ (hl.unbind が効いている)
#    modmask=65 = SUPER(64) + SHIFT(1)
omarchy menu keybindings --print \
  | grep SLASH                             # => SUPER SHIFT + SLASH → Passwords

# 起動 (期待値)
omarchy-launch-or-focus '^Bitwarden$' 'uwsm-app -- bitwarden-desktop'
hyprctl clients -j | jq '.[] | select(.class=="Bitwarden") | {floating, size}'
# => floating=true, size=[875,600] (論理px、倍率 1.8 のとき)
```

> **スクショで確かめようとすると真っ黒に見えるが正常。** 下の「1. 画面共有除外」の仕様。
> 見た目の確認は実画面で行う。

## ハマりどころ

1. **スクリーンショットに映らない (grim で真っ黒)。** これはバグではなく、
   Omarchy 既定のウィンドウルール `no_screen_share = true` の仕様。
   Bitwarden の窓は `grim` や画面共有で**真っ黒な矩形**として写る。
   描画が死んでいるわけではない。本当に生きているかはレンダラプロセスで判断する:

   ```bash
   for d in /proc/[0-9]*; do tr '\0' ' ' < $d/cmdline 2>/dev/null; echo; done \
     | grep -c -- "--type=renderer"       # => 1以上 (Bitwarden のレンダラが居る)
   ```

   確認方法: foot など別の窓に
   `hyprctl eval 'o.window("^(foot)$", { no_screen_share = true })'` を当てると
   その窓も真っ黒になり、`hyprctl reload` で元に戻る。
   (`hyprctl keyword` は `can't work with non-legacy parsers` で不可。`eval` を使う。
   動的に当てたルールは `hyprctl reload` で消える)
2. **`SUPER + SHIFT + SLASH` (Passwords) は既定で 1Password を指している。**
   `/usr/share/omarchy/default/hypr/bindings/applications.lua` の
   `o.bind("SUPER + SHIFT + SLASH", "Passwords", { omarchy = "1password" })`。
   上記のとおり `hl.unbind` + `o.bind` で差し替える。
3. **Electron アプリはスケーリングで巨大になりやすい。** Omarchy 自身が 1Password 用に
   `--force-device-scale-factor=1` を当てている (`/usr/share/omarchy/bin/omarchy-launch-1password`)。
   Bitwarden には対策が無いので、表示倍率を上げていて窓が大きすぎると感じたら
   `bitwarden-desktop --force-device-scale-factor=1` で起動するか、
   `~/.local/share/applications/bitwarden.desktop` を作って `Exec` に足す。
   倍率自体は `~/.config/hypr/monitors.lua` の `omarchy_monitor_scale` で決まる。
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
