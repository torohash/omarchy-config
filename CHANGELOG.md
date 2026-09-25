# CHANGELOG (索引)

このリポジトリで扱う設定変更の索引。詳細な手順・知見は右のファイルへ。
1行 = 1変更。新しいものを上に追記する。詳細はできるだけ `apps/` 側に書き、ここは
「いつ・何を・なぜ・詳細はどこ」だけを簡潔に保つ。

| 日付 | 変更 | 対象 | 詳細 |
|------|------|------|------|
| 2026-09-25 | Claude Code のオプトアウト (テレメトリ・エラー報告・評価アンケート) を `settings.json` の `env` に設定。Nix ではなく手順書で管理 (Omarchy と Claude Code も書くファイルのため) | `~/.claude/settings.json` | [apps/claude-code.md](apps/claude-code.md) |
| 2026-09-25 | 候補ウィンドウを Omarchy のテーマに追従する自作テーマ `omarchy` (Soft デザイン) に置き換え、フォントを Noto Sans CJK JP に (Sans だと漢字が KR 字形)。3 案 (Omarchy / Soft / Bold) をスクショ比較して Soft を採用 | `~/.config/omarchy/themed/fcitx5-*.tpl` / `hooks/theme-set.d/fcitx5-theme` / `~/.config/fcitx5/conf/classicui.conf` | [apps/fcitx5-mozc.md](apps/fcitx5-mozc.md) |
| 2026-09-25 | herdr の移動キーを入れ替え: workspace を `prefix+,` `.`、agent を `prefix+shift+,` `.` にする | `~/.config/herdr/config.toml` | [apps/herdr.md](apps/herdr.md) |
| 2026-09-25 | Nix を `omarchy pkg add nix` で導入し、flakes を有効化。nix-config に Omarchy 用の構成 (Omarchy 優先・エージェント設定だけ Nix) を用意する方針に決定 | `nix` (`extra`) / `nix-daemon.socket` / `~/.config/nix/nix.conf` | [apps/nix.md](apps/nix.md) |
| 2026-09-25 | Turso CLI を mise で導入 (AUR / Nix ではなく Omarchy と同じ mise 経路) | `turso` (mise, `aqua:tursodatabase/turso-cli`) | [apps/turso.md](apps/turso.md) |
| 2026-09-25 | Zed (エディタ) を導入。Arch は CLI 名が `zeditor` なので `zed` symlink を追加 | `zed`, `omazed` (`extra`) / `~/.local/bin/zed` | [apps/zed.md](apps/zed.md) |
| 2026-09-25 | GitHub のホスト鍵を公式 HTTPS API から取得し、SSH の初回検証を有効にする | `~/.ssh/known_hosts` | [apps/github-ssh.md](apps/github-ssh.md) |
| 2026-09-25 | ブラウザを Chrome にして既定にする | `google-chrome` (AUR) / xdg default-web-browser | [apps/browser.md](apps/browser.md) |
| 2026-09-25 | Discord の Web アプリ版ランチャーを削除 (ネイティブと重複) | `~/.local/share/applications/Discord.desktop` | [apps/discord.md](apps/discord.md) |
| 2026-09-25 | Discord (公式クライアント) を導入 | `discord` (`extra`) | [apps/discord.md](apps/discord.md) |
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
| 2026-09-24 | herdr prefix `ctrl+space`→`ctrl+b` | `~/.config/herdr/config.toml` | [apps/herdr.md](apps/herdr.md) |

## 新規ホストへの適用手順

→ [setup/new-host.md](setup/new-host.md)

## バックアップ

上書きする前に元ファイルを `backups/` に退避する(差分を見る・戻すとき用)。

- `herdr-config.toml.omarchy-backup` … Omarchy 版 herdr config (比較用)
- `herdr-config.toml.before-agent-ws-keys` … agent/workspace キー追加前の config
- `herdr-config.toml.before-swap-agent-ws` … workspace / agent の移動キーを入れ替える前の config
- `fcitx5-classicui.conf.before-redesign` … 候補ウィンドウを作り直す前の classicui.conf
- `fcitx5-theme-omarchy-tokyo-night/` … 置き換える前の自作テーマ一式 (Tokyo Night 直書き)
- `claude-settings.json.before-optout` … オプトアウト設定を入れる前の `~/.claude/settings.json`
- `hypr-bindings.lua.before-bitwarden` … Passwords キーを Bitwarden に向ける前の bindings.lua
