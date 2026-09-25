# omarchy-config

新しい [Omarchy](https://omarchy.org/) マシンを、いつもの環境にすばやく構築するためのリポジトリ。
手順はエージェント (Claude Code / Pi) が読んで実行できる skill として書いてある。

## 使い方

```bash
git clone https://github.com/torohash/omarchy-config ~/dev/config
cd ~/dev/config
claude        # または pi
```

エージェントに「セットアップして」と頼む。メインの手順書 (skill `omarchy-setup`) が次の順で進める。

1. 各作業がもう済んでいるかを調べる (`status.sh`)
2. 任意の作業 (アプリなど) を入れるか聞く
3. sudo が要る操作をまとめて 1 つの端末で実行する (パスワードは 1 回)
4. ブラウザでのログインなど、人にしかできない操作をまとめて案内する
5. 残りの作業を順に実行し、最後に全体を検証する

特定の作業だけなら「herdr の設定をして」のように頼むか、`/herdr` (Claude Code) / `/skill:herdr` (Pi) で呼ぶ。

## 構成

```
.agents/skills/
├── omarchy-setup/   メインの手順書 (順番は files/order.txt)
├── add-task/        作業 skill の書き方
└── <作業>/          SKILL.md (手順) / reference.md (理由・経緯・ハマりどころ) / files/ (配るファイル)
.claude/skills  ->  .agents/skills
```

| 作業 | 内容 |
|------|------|
| `hyprland-input` | キーボード配列 US、タッチパッドの自然スクロール |
| `fcitx5-mozc` | 日本語入力 (Ctrl+Space)、テーマに追従する候補ウィンドウ |
| `herdr` | herdr を左手だけで操作 (prefix `alt+s`、A / D で移動、Shift+C で新しい workspace) |
| `github` | `gh auth login` の案内、GitHub の SSH ホスト鍵 |
| `claude-code-optout` | Claude Code のテレメトリ等を止める |
| `nix-home-manager` | Nix + [nix-config](https://github.com/torohash/nix-config) (Claude Code の CLAUDE.md、Pi の設定) |
| `pi-packages` | Pi の拡張 |
| `agent-photo-sync` | スマホの写真を Pi / Claude Code で受け取る (拡張・MCP・ufw) |
| `display-scale` | Display パネルの倍率スライダー (任意) |
| `voxtype` | 音声入力の日本語化 (任意) |
| `chrome` / `bitwarden` / `discord` / `zed` / `turso` | アプリ (任意) |

作業の追加・変更のルールは [AGENTS.md](AGENTS.md) と skill `add-task`。
