# CHANGELOG (索引)

このマシンに行った設定変更の索引。詳細な手順・知見は右のファイルへ。
1行 = 1変更。新しいものを上に追記する。詳細はできるだけ `apps/` 側に書き、ここは
「いつ・何を・なぜ・詳細はどこ」だけを簡潔に保つ。

| 日付 | 変更 | 対象 | 詳細 |
|------|------|------|------|
| 2026-09-25 | `SUPER+SHIFT+/` (Passwords) を 1Password → Bitwarden に差し替え | `~/.config/hypr/bindings.lua` | [apps/bitwarden.md](apps/bitwarden.md) |
| 2026-09-25 | 表示倍率 1.6x → 1.8x (2x は大きすぎ / 1.6x は小さい) | `~/.config/hypr/monitors.lua` | [apps/display-scale.md](apps/display-scale.md) |
| 2026-09-25 | Display パネルの SCALE を 6ボタン → 11段スライダーに (clone `torohash.monitor`) | `~/.config/omarchy/plugins/torohash.monitor/` | [apps/display-scale.md](apps/display-scale.md) |
| 2026-09-24 | Bitwarden (デスクトップ + CLI `bw`) を導入 | `bitwarden`, `bitwarden-cli` (`extra`) | [apps/bitwarden.md](apps/bitwarden.md) |
| 2026-09-24 | 音声入力モデルは `small` で確定、`large-v3-turbo` を削除 | `~/.local/share/voxtype/models/` | [apps/voxtype.md](apps/voxtype.md) |
| 2026-09-24 | Voxtype を日本語化 (small/ja/VAD/Vulkan) | `~/.config/voxtype/config.toml` | [apps/voxtype.md](apps/voxtype.md) |
| 2026-09-24 | Voxtype (音声入力) を導入 | `voxtype-bin`, `wtype` | [apps/voxtype.md](apps/voxtype.md) |
| 2026-09-24 | 候補ウィンドウを自作 Tokyo Night テーマに | `~/.local/share/fcitx5/themes/omarchy-tokyo-night/` | [apps/fcitx5-mozc.md](apps/fcitx5-mozc.md) |
| 2026-09-24 | Mozc を導入し fcitx5 に登録 | `fcitx5-mozc`, `~/.config/fcitx5/profile` | [apps/fcitx5-mozc.md](apps/fcitx5-mozc.md) |
| 2026-09-24 | キーボード `jp`→`us` / タッチパッド natural_scroll 反転 | `~/.config/hypr/input.lua` | [apps/hyprland-input.md](apps/hyprland-input.md) |
| 2026-09-24 | agent/workspace の移動キーを追加 (`prefix+,` `.`) | `~/.config/herdr/config.toml` | [apps/herdr.md](apps/herdr.md) |
| 2026-09-24 | herdr キーバインドを本体デフォルトに戻す | `~/.config/herdr/config.toml` | [apps/herdr.md](apps/herdr.md) |
| 2026-09-24 | herdr prefix `ctrl+space`→`ctrl+b` (← 上の reset に内包) | `~/.config/herdr/config.toml` | [apps/herdr.md](apps/herdr.md) |

## 新規ホストへの適用手順

→ [setup/new-host.md](setup/new-host.md)

## バックアップ

`backups/` に変更前の設定を退避している。

- `herdr-config.toml.omarchy-backup` … herdr 純正化前の Omarchy 版 config
- `herdr-config.toml.before-agent-ws-keys` … agent/workspace キー追加直前の config
- `hypr-bindings.lua.before-bitwarden` … Passwords キーを Bitwarden に差し替える直前の bindings.lua
