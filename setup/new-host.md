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
omarchy pkg add fcitx5-material-color  # 候補ウィンドウのテーマ
# agent から: pkexec pacman -S --noconfirm --needed fcitx5-mozc fcitx5-material-color

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

# 候補ウィンドウのテーマ
mkdir -p ~/.config/fcitx5/conf
cat > ~/.config/fcitx5/conf/classicui.conf <<'EOF'
Theme=Material-Color-Blue
PerScreenDPI=True
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

## 2. herdr (ターミナルワークスペースマネージャ)

Omarchy 同梱。**キーは herdr 純正デフォルトに戻し**、agent/workspace 移動だけ追加する。
(Omarchy 版は `ctrl+space` prefix で IME と衝突するため)

```bash
# 純正キーに戻す (自動バックアップされる)
herdr config reset-keys

# agent / workspace 移動キーを追記 (~/.config/herdr/config.toml の末尾)
cat >> ~/.config/herdr/config.toml <<'EOF'

[keys]
previous_agent = "prefix+comma"
next_agent = "prefix+period"
previous_workspace = "prefix+shift+comma"
next_workspace = "prefix+shift+period"
EOF

herdr config check            # => config: ok
herdr server reload-config    # => applied
```

確認: `omarchy-menu-herdr-keybindings --print`

→ 詳細: [../apps/herdr.md](../apps/herdr.md)

---

## 3. Hyprland input (キーボード配列 / タッチパッド)

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

## 4. インストールされるパッケージ一覧

| パッケージ | 版 (参考) | 用途 |
|-----------|----------|------|
| `fcitx5`, `fcitx5-gtk`, `fcitx5-qt` | 5.1.22-1 等 | Omarchy 標準 |
| `fcitx5-mozc` | 3.34.6239.2-1 | 日本語入力 |
| `fcitx5-material-color` | 0.2.1-2 | 候補ウィンドウのテーマ |
| `keyd` (任意) | 2.6.0-5 | Caps Lock を IME 切替に remap |

`flatpak` / `snap` は**導入しない** (Omarchy は pacman + AUR で完結)。

---

## 5. 変更ファイル一覧

| ファイル | 内容 |
|----------|------|
| `~/.config/fcitx5/profile` | keyboard-us + mozc |
| `~/.config/fcitx5/conf/classicui.conf` | Theme=Material-Color-Blue |
| `~/.config/herdr/config.toml` | 純正キー + agent/workspace 移動 |
| `~/.config/hypr/input.lua` | kb_layout=us, natural_scroll=true |

---

## 6. 更新で戻されるので注意

- `omarchy-refresh-herdr` … herdr 設定を Omarchy 既定 (`ctrl+space`) に上書き。
- `omarchy refresh hyprland` … `~/.config/hypr/*.lua` を既定に戻す。
- fcitx5 は終了時に設定を書き戻すため、手書き後はプロセス再起動で読ませる。

システム更新後に効かなくなったら、この手順を再実行する。
