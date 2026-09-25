# Nix + Home Manager — 理由・ハマりどころ

手順は [SKILL.md](SKILL.md)。

## 何を Nix で扱うか

[torohash/nix-config](https://github.com/torohash/nix-config) は Ubuntu / Fedora / WSL / Omarchy 共通の構成。
Omarchy では **Omarchy を優先**し、Home Manager が扱うのは次だけ (nix-config の `docs/omarchy.md` に持ち主の一覧がある)。

| ファイル | 中身 |
|---------|------|
| `~/.claude/CLAUDE.md` | Claude Code のグローバル指示: 回答は日本語、コミット・PR に Claude の署名を入れない |
| `~/.pi/agent/models.json` | gpt-5.6-sol / gpt-6 系の context を 1,050,000 トークンに広げる |
| `~/.pi/web-search.json` | pi-web-access の検索順 (openai → parallel-mcp → exa) |
| `~/.pi/agent/settings.json` の `compaction` | 約 900,000 トークンで自動圧縮 (`reserveTokens` 150,000)。ほかのキーは残す |

バイナリは Nix で入れない (Omarchy の pacman / mise を使う)。flake の検査 `omarchy-ownership-medium` が、
Omarchy の持ち物 (`.bashrc`・git・nvim・端末・herdr・fcitx5 など) を Home Manager が持たないことを保証する。

## Nix の入れ方

| 候補 | 採否 | 理由 |
|------|------|------|
| `omarchy pkg add nix` (Arch `extra/nix`) | **採用** | `omarchy update` で一緒に更新される |
| 公式インストーラー (curl \| sh) | 不採用 | `/etc` やシェルの設定を自分で書き換え、更新も別管理になる |
| mise | 不可 | Nix はユーザー領域の CLI ではない (`/nix/store` と daemon が要る) |

## ハマりどころ

- **`nix-users` グループは無い**: Arch の `nix` が作るのは `nixbld` だけ。`usermod -aG nix-users` は
  `group 'nix-users' does not exist` (終了コード 6) で失敗する。`allowed-users` は既定で `*` なので不要。
- **flakes は既定で無効**。`~/.config/nix/nix.conf` に書く。
- **`home-manager` は今開いている端末では見つからない**: PATH は `/etc/profile.d/nix-daemon.sh` がログイン時に足す。
- **`~/.claude/CLAUDE.md` は symlink (読み取り専用)**: Claude Code の `/memory` などで直接編集すると失敗する。nix-config の `dotfiles/claude/CLAUDE.md` を直して switch する。
- **`~/.pi/agent/settings.json` を symlink にしない**: Omarchy のテーマ切替 (`theme`) と Pi 自身が書き込む。
  Home Manager は activation で `compaction` だけをマージする。
- Pi の package は Home Manager で管理しない (skill `pi-packages`)。activation で `packages` を丸ごと書くと、
  `pi install` で足したものが switch のたびに消えるため。
