# 新規ホストへの適用手順

新しい Omarchy マシンにこの環境の設定を再現するための手順。
前提: Omarchy インストール済み (Hyprland / Omarchy shell 動作)。

詳細な背景・ハマりどころは各 `apps/*.md` を参照。

---

## 0. 前提確認

```bash
cat /etc/os-release | head -3        # NAME=Omarchy を確認
pacman -Q fcitx5 fcitx5-gtk fcitx5-qt  # 標準で入っているはず
pacman -Qq yay                       # AUR ヘルパー
```

特権の使い分け (Omarchy スキル準拠):
- ターミナルでパスワード入力可 → `sudo` / `omarchy pkg add`
- agent など非対話 → `pkexec`

---

## 1. 日本語入力 (fcitx5 + Mozc)

```bash
# パッケージ
omarchy pkg add fcitx5-mozc            # または sudo pacman -S fcitx5-mozc
# agent から: pkexec pacman -S --noconfirm --needed fcitx5-mozc

# プロファイル (~/.config/fcitx5/profile)
cat > ~/.config/fcitx5/profile <<'EOF'
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=keyboard-us

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=mozc
Layout=

[GroupOrder]
0=Default
EOF

# 候補ウィンドウ: 自作 Tokyo Night テーマを配置
mkdir -p ~/.local/share/fcitx5/themes
cp -r ~/dev/config/assets/omarchy-tokyo-night ~/.local/share/fcitx5/themes/

mkdir -p ~/.config/fcitx5/conf
cat > ~/.config/fcitx5/conf/classicui.conf <<'EOF'
Theme=omarchy-tokyo-night
UseAccentColor=False
PerScreenDPI=True
Font=Sans 12
MenuFont=Sans 12
EOF

# 反映 (Omarchy 作法)
omarchy restart xcompose
```

確認:

```bash
fcitx5-remote -n          # keyboard-us
fcitx5-remote -t          # mozc (state=2) になるか
fcitx5-remote -t          # 戻す
```

→ 詳細: [../apps/fcitx5-mozc.md](../apps/fcitx5-mozc.md)

---

## 2. 音声入力 (Voxtype) — 任意

Omarchy の初回通知から入れられる。**既定は英語専用**なので日本語化が必須。

```bash
omarchy voxtype install     # 通知クリックでも同じ

# 日本語化 (モデルと言語の両方)
voxtype setup --download --model small --activate   # 多言語モデル 466MB
voxtype config set whisper.language ja

# 無音の幻覚対策 (VAD は既定 OFF)
voxtype setup vad                                   # Silero 0.8MB
voxtype config set vad.enabled true
voxtype config set vad.backend whisper

# 内蔵GPU があれば Vulkan 加速
sudo voxtype setup gpu --enable

systemctl --user restart voxtype
```

確認:

```bash
voxtype setup check          # All checks passed
voxtype setup gpu --status   # GPU (Vulkan) - active
```

→ 詳細: [../apps/voxtype.md](../apps/voxtype.md)

---

## 3. herdr (ターミナルワークスペースマネージャ)

Omarchy 同梱。**キーは herdr 純正デフォルトに戻し**、workspace/agent 移動だけ追加する。
(Omarchy 版は `ctrl+space` prefix で IME と衝突するため)

```bash
# 純正キーに戻す (自動バックアップされる)
herdr config reset-keys

# workspace / agent 移動キーを追記 (~/.config/herdr/config.toml の末尾)
cat >> ~/.config/herdr/config.toml <<'EOF'

[keys]
previous_workspace = "prefix+comma"
next_workspace = "prefix+period"
previous_agent = "prefix+shift+comma"
next_agent = "prefix+shift+period"
EOF

herdr config check            # => config: ok
herdr server reload-config    # => applied
```

確認: `omarchy-menu-herdr-keybindings --print`

→ 詳細: [../apps/herdr.md](../apps/herdr.md)

---

## 4. Hyprland input (キーボード配列 / タッチパッド)

`~/.config/hypr/input.lua` の末尾に追記:

```lua
hl.config({
  input = {
    kb_layout = "us",
    touchpad = {
      natural_scroll = true,
    },
  },
})
```

反映・検証:

```bash
hyprctl reload
hyprctl configerrors          # 空であること
hyprctl getoption input:kb_layout
hyprctl getoption input:touchpad:natural_scroll
```

→ 詳細: [../apps/hyprland-input.md](../apps/hyprland-input.md)

---

## 5. 表示倍率 (Display パネルのスライダー化) — 任意

Omarchy の Display パネルの SCALE は 6個の固定ボタン (`1/1.25/1.6/2/3/4`)。
中間が欲しいので **11段のスライダーに差し替える**。

```bash
# 1. 雛形を複製 (bar widget の差し替えまで自動)
omarchy plugin clone omarchy.monitor

# 2. 改造版 Panel.qml を上書き
cp ~/dev/config/assets/torohash.monitor/Panel.qml \
   ~/.config/omarchy/plugins/$(whoami).monitor/Panel.qml

# 3. QML は hot-reload されないので shell 再起動
omarchy restart shell
```

倍率を変える (パネルのスライダーでも CLI でも可):

```bash
omarchy hyprland monitor scaling 1.8    # 数値指定。`up`/`down` は 1.6→2 に飛ぶので不可
hyprctl monitors -j | jq '.[0].scale'   # => 1.8
```

**注意:** Hyprland が取れる倍率は `gcd(w*120, h*120)` の約数のみ。
2880x1800 では 1.6〜2.0 の中間は **1.667 / 1.8 / 1.875** の3つだけ。

確認:

```bash
omarchy plugin validate ~/.config/omarchy/plugins/$(whoami).monitor   # => exit 0
omarchy-shell omarchy.monitor state | jq -r .scale                    # => 1.8
```

→ 詳細: [../apps/display-scale.md](../apps/display-scale.md)

---

## 6. Bitwarden (パスワードマネージャ) — 任意

Omarchy のメニューに**公式の導線**がある (Install → Bitwarden)。
入れているのは 1Password ではなく **Bitwarden** である点に注意。

```bash
# メニュー相当の CLI (フローティング端末でインストール → 起動)
omarchy install and launch Bitwarden 'bitwarden bitwarden-cli' bitwarden

# 手で入れるなら
omarchy pkg add bitwarden bitwarden-cli
```

両方とも **`extra` (公式リポジトリ)**。AUR / yay は不要。
`bitwarden-cli` は `nodejs-lts-jod` に依存する。

確認:

```bash
pacman -Q bitwarden bitwarden-cli   # => 2026.3.1-2 / 2026.2.0-1
bw --version                        # => 2026.2.0
gtk-launch bitwarden                # GUI 起動 → ログイン
```

注意点:

- 金庫 ( `~/.config/Bitwarden/data.json` ) は**リポジトリにコピーしない**。
- **`SUPER+SHIFT+/` (Passwords) は既定で 1Password を指している**ので Bitwarden へ差し替える。
  `~/.config/hypr/bindings.lua` に (変更前は `backups/hypr-bindings.lua.before-bitwarden`):

  ```lua
  hl.unbind("SUPER + SHIFT + SLASH")   -- 既定: o.bind(..., { omarchy = "1password" })
  o.bind("SUPER + SHIFT + SLASH", "Passwords", { launch = "bitwarden-desktop", focus = "^Bitwarden$" })
  ```

  検証: `hyprctl reload && hyprctl configerrors` (空) / `hyprctl binds -j | jq '.[] | select(.description=="Passwords")'` が **1件だけ**。
  バイナリ名は `bitwarden-desktop` (`bitwarden` というコマンドは無い)。
- ウィンドウルール (フローティング + **画面共有除外**) は Omarchy が既に持っている
  (`default/hypr/apps/bitwarden.lua`) ので何もしなくてよい。ただしこの除外のせいで
  **Bitwarden の窓は `grim` で真っ黒に写る** (バグではない)。描画確認は実画面か
  レンダラプロセスの有無で行う。
- Electron なので表示倍率が高いと窓が大きめに出ることがある。
  `--force-device-scale-factor=1` で調整できる(倍率 1.8 では 875x600 で普通)。

→ 詳細: [../apps/bitwarden.md](../apps/bitwarden.md)

---

## 7. Discord (チャット) — 任意

公式クライアント。**`extra` にあるので AUR 不要**。入れるだけでなく初回起動で本体をDLする点に注意。

```bash
omarchy pkg add discord
omarchy pkg add libappindicator-gtk3   # 任意: バーのトレイに出す

discord                                # 初回起動で本体 (~500MB) を ~/.config/discord/ にDL
```

注意: Omarchy は Discord の **Web アプリ版ランチャー** (`Discord.desktop`) も持っているので、
ネイティブを入れるとランチャーに "Discord" が2つ並ぶ。片方にする:

```bash
omarchy webapp remove Discord          # Web アプリ版のランチャーを消す
```

確認:

```bash
pacman -Q discord                       # => discord 1:1.0.156-1 など
hyprctl clients -j | jq '.[] | select(.class=="discord") | {xwayland, floating}'
# => xwayland=false (Wayland ネイティブ)
```

注意点:

- **初回起動にネットが必要**。本体はパッケージに含まれない (`~/.config/discord/` に約500MB)。
- 撤去は `sudo pacman -Rns discord` + `rm -rf ~/.config/discord`。
- 画面共有は `xdg-desktop-portal-hyprland` 経由 (Omarchy が導入済み + `xdph.conf` 設定済み)。
  `no_screen_share` な窓は共有しても真っ黒になる。
- クライアントを入れたくない場合は **Web アプリ版**が既にある (`Discord.desktop`)。

→ 詳細: [../apps/discord.md](../apps/discord.md)

---

## 8. Zed (エディタ) — 任意

Arch の `zed` パッケージ。**CLI 名が `zeditor`** なので、`zed .` を使うには symlink が要る。

```bash
omarchy install editor zed      # zed + omazed (テーマ同期 hook) を入れて起動
# エージェントからは: omarchy-launch-floating-terminal-with-presentation 'omarchy-install-editor-zed'

ln -s /usr/bin/zeditor ~/.local/bin/zed   # `zed` コマンドを生やす (sudo 不要)
```

`/usr/bin/zed` は ZFS の `zed` (`zfs-utils`) と衝突するため、Arch が CLI を `zeditor` に
リネームしている。GUI 本体は `/usr/lib/zed/zed-editor`、ランチャーは
`dev.zed.Zed.desktop` (`Exec=zeditor %U`)。

確認:

```bash
which zed        # => ~/.local/bin/zed
zed --version    # => Zed 1.18.1 – /usr/lib/zed/zed-editor
```

注意: Omarchy は `~/.local/bin` を PATH の末尾に足すので、`zfs-utils` を入れると
`/usr/bin/zed` (ZFS Event Daemon) が優先される。そのときは `zeditor` を使う。

→ 詳細: [../apps/zed.md](../apps/zed.md)

---

## 9. CLI ツール (mise でグローバル)

`gh` / `node` / `pi` / `codex` のような CLI は **mise でグローバル管理**する
(pacman では入れない。`gh` の pacman パッケージ名は `github-cli` で紛らわしく、
両方入れると二重管理になる)。

```bash
mise use -g gh          # ~/.config/mise/config.toml に追記される
mise use -g node@lts pi codex
mise use -g turso        # Turso CLI (→ ../apps/turso.md)
mise ls --global        # 入っているもの一覧
gh auth login           # 認証 (ブラウザ or トークン)
```

- 設定・認証は `~/.config/gh/` に人る(ホスト単位のグローバル)。
- shim は `~/.local/share/mise/shims/gh`。PATH に `~/.local/share/mise/shims` が必要。
- **Omarchy の `omarchy install dev-env <lang>` とは別系統**。言語によっては
  Omarchy 側の手順を優先する。

確認:

```bash
gh --version            # => gh version 2.x
mise ls --global | grep gh
```

### GitHub を SSH remote で使う場合

`gh auth login` とは別に、GitHub のホスト鍵を `~/.ssh/known_hosts` に登録する。
初回接続を非対話で行うと `Host key verification failed` になり得るため、
公式の鍵を確認してから登録する。検証を無効化して回避しない。

→ 登録手順・SSH 認証と Git アクセスの検証: [../apps/github-ssh.md](../apps/github-ssh.md)

---

## 10. インストールされるパッケージ一覧

| パッケージ | 版 (参考) | 用途 |
|-----------|----------|------|
| `fcitx5`, `fcitx5-gtk`, `fcitx5-qt` | 5.1.22-1 等 | Omarchy 標準 |
| `fcitx5-mozc` | 3.34.6239.2-1 | 日本語入力 |
| `voxtype-bin` + `wtype` (任意) | 1.0.1-1 | 音声入力 (Omarchy リポジトリ) |
| `keyd` (任意) | 2.6.0-5 | Caps Lock を IME 切替に remap |
| `fcitx5-material-color` (任意) | 0.2.1-2 | 既製テーマ。自作テーマを使うなら不要 |
| `bitwarden` (任意) | 2026.3.1-2 | パスワードマネージャ (Electron 39 同梱依存) |
| `bitwarden-cli` (任意) | 2026.2.0-1 | `bw`。nodejs-lts-jod に依存 |
| `discord` (任意) | 1:1.0.156-1 | チャット。初回起動で本体 (~500MB) をDLする |
| `zed` (任意) | 1.18.1-1 | エディタ。CLI は `zeditor` という名前 |
| `omazed` (任意) | 2.1.2-1 | Omarchy テーマを Zed に同期する hook |

> `gh` などの CLI は **mise 管理**(pacman では入れない) → 節「9. CLI ツール (mise でグローバル)」参照。

`flatpak` / `snap` は**導入しない** (Omarchy は pacman + AUR で完結)。

---

## 11. 変更ファイル一覧

| ファイル | 内容 |
|----------|------|
| `~/.config/fcitx5/profile` | keyboard-us + mozc |
| `~/.config/fcitx5/conf/classicui.conf` | Theme=omarchy-tokyo-night |
| `~/.local/share/fcitx5/themes/omarchy-tokyo-night/` | 自作候補ウィンドウテーマ (assets/ からコピー) |
| `~/.config/voxtype/config.toml` | model=small, language=ja, VAD有効 |
| `~/.config/herdr/config.toml` | 純正キー + agent/workspace 移動 |
| `~/.config/hypr/input.lua` | kb_layout=us, natural_scroll=true |
| `~/.config/hypr/monitors.lua` | omarchy_monitor_scale=1.8 (gdk_scale=2 のまま) |
| `~/.config/omarchy/plugins/torohash.monitor/Panel.qml` | SCALE を11段スライダー化 (assets/ からコピー) |
| `~/.config/omarchy/shell.json` | bar widget を `omarchy.monitor` → `torohash.monitor` |
| `~/.config/Bitwarden/` | デスクトップアプリの金庫 (**コピーしない**) |
| `~/.local/bin/zed` | `/usr/bin/zeditor` への symlink (端末の `zed` コマンド用) |

---

## 12. 更新で戻されるので注意

- `omarchy-refresh-herdr` … herdr 設定を Omarchy 既定 (`ctrl+space`) に上書き。
- `omarchy refresh hyprland` … `~/.config/hypr/*.lua` を既定に戻す。
- fcitx5 は終了時に設定を書き戻すため、手書き後はプロセス再起動で読ませる。
- `/usr/share/omarchy/` は `omarchy update` で上書きされる。Display パネルの改造は
  clone 側 (`~/.config/omarchy/plugins/`) にあるので生き残るが、`omarchy plugin clone`/
  `enable` の再実行が要る場合はある。倍率も `omarchy refresh hyprland` で 1.6 に戻る。

システム更新後に効かなくなったら、この手順を再実行する。
