# Agent PhotoSync — 仕組み・理由・ハマりどころ

手順は [SKILL.md](SKILL.md)。詳しい仕様はリポジトリの README と `docs/protocol.md`。

## 何をするものか

Android で撮った写真を、同じ LAN の Pi / Claude Code に渡す。アプリの一覧に Pi と Claude Code のセッションが並ぶ。

- **Pi**: 拡張 (`extensions/photosync.ts`)。受信した画像を入力欄に添付し、文章と一緒に送れる。
  コマンド `/photosync status` `/photosync receive` `/photosync clear` `/photosync web-origin <URL>`。
- **Claude Code**: MCP サーバー (`packages/claude-code/src/server.ts`)。「写真を見て」と頼むと `get_photos` で受け取る。
  ほかに `photosync_status`、`photosync_receive` (このセッションを受信先にする)。
- どちらも受信しただけではモデルを呼ばない。
- 「PC 側で指定」の受信先は `~/.local/state/agent-photosync` で共有する (Pi と Claude Code の間でも切り替わる)。

## 登録のしかた

| 相手 | 方法 | 理由 |
|------|------|------|
| Pi | `pi install ~/dev/agent-photo-sync` (グローバル) | すべてのプロジェクトで使うため。settings.json には `../../dev/agent-photo-sync` (`~/.pi/agent` からの相対パス) で入る |
| Claude Code | `claude mcp add --scope user` で `mise exec -C <repo> -- node …` | Node.js は `mise.toml` で固定した版を使う (TypeScript を直接実行するため 22.18 以降が必要) |

Claude Code は MCP ツールを呼ぶたびに確認を求める。`~/.claude/settings.json` の `permissions.allow` に
`mcp__photosync` (このサーバーの全ツール。`mcp__photosync__*` と同じ) を足して確認なしにする。
写真の受け取りと状態の表示だけで、ファイルやシェルには触らないため全許可でよい。
`settings.json` は Omarchy のテーマ切替と Claude Code 自身も書くので、Nix の symlink にせず jq で足す。

ローカルのリポジトリなので、skill `pi-packages` の `packages.txt` には書かない (clone していないホストで壊れるため)。

## ネットワーク

- IPv4 と mDNS (UDP 5353) でセッションを探す。
- 受信はセッションごとに TCP 47800〜47819 の空いている番号を 1 つ使う (同時に 20 セッションまで)。
  範囲は環境変数 `PHOTOSYNC_PORT_RANGE` (例 `48000-48009`) で変えられる。変えたら ufw の規則も合わせる。
- Omarchy の ufw は受信を既定で拒否する (`ufw default deny incoming`)。LAN からの 5353/udp と 47800:47819/tcp を許可する。
- **インターネットには公開しない**。許可するのは今つながっている LAN (例 `192.168.0.0/24`) だけにする。

## ハマりどころ

- **LAN が変わるとアプリから見えない**: ufw の規則は許可したサブネットだけ。別の LAN (サブネットが違う) で使うなら、
  そのサブネットの規則を足す。外出先の LAN は許可しない。
- `/etc/ufw/user.rules` のコメントは 16 進数で保存されるので、`Agent PhotoSync` では検索できない。ポート番号で探す。
- **`mise trust` を忘れると `mise install` / `mise exec` が止まる** (プロジェクトの `mise.toml` が信頼されていない)。
- `mise install` を引数なしで実行すると Flutter・Android SDK・Java まで入る。PC 側の受信には `node` だけでよい。
- Pi は拡張の読み込み・`/reload`・会話の切り替えで受信先 ID が変わる。
- Web 版から送るときは、接続元の URL の許可が要る (Claude Code は登録時に `-e PHOTOSYNC_WEB_ORIGIN=http://127.0.0.1:8080`)。
