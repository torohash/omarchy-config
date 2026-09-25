# AGENTS.md

新しい Omarchy マシンの環境を、エージェント (Claude Code / Pi) に素早く構築させるためのリポジトリ。
作業は 1 つずつ skill (`.agents/skills/<name>/`) になっている。`.claude/skills` はその symlink。

## 何をするか

| 頼まれたこと | 使う skill |
|-------------|-----------|
| 環境を構築する・どこまで済んでいるか確かめる | **`omarchy-setup`** (メインの手順書) |
| 特定の作業だけ行う・直す (例:「herdr の設定をして」) | その作業の skill (一覧は `omarchy-setup`) |
| 新しい作業を追加する・既存の作業を書き直す | **`add-task`** |

`~/.config/hypr/` や `~/.config/omarchy/` などを触る前に、Omarchy スキル (`omarchy`) を読む。

## 構成

```
~/dev/config/
├── AGENTS.md                  # これ (入口)
├── README.md                  # 人間向けの概要
├── .agents/skills/
│   ├── omarchy-setup/         # メインの手順書 + status.sh / run-privileged.sh / order.txt
│   ├── add-task/              # 作業 skill の書式とルール
│   └── <作業>/                # SKILL.md = 手順 / reference.md = 理由・経緯 / files/ = 配るファイル
└── .claude/skills -> ../.agents/skills
```

## 共通のルール

- **インストールは Omarchy 経由** (`omarchy pkg add` / `omarchy pkg aur add` / `omarchy install ...` / `mise use -g`)。
  素の `pacman -S` や `pkexec pacman` は使わない。入れる前に、Omarchy が最初から入れていないか確かめる。
- **sudo はエージェントの bash では使えない** (TTY が無い)。特権の操作は `omarchy-setup` の
  `run-privileged.sh` でフローティング端末にまとめ、ユーザーにパスワードを 1 回だけ入れてもらう。
- **`/usr/share/omarchy/` は編集しない** (`omarchy update` で消える)。読むのは自由。
- **変更前に現在の値を確認し**、上書きするファイルは `~/.local/state/omarchy-config/backups/` に退避する
  (リポジトリには置かない)。
- 変更したら skill の「検証」を実行し、期待される出力と合うことを確かめる。

## このリポジトリを編集するとき

- 書式とルールは skill `add-task` に従う。特に **状態を書かない** (「このマシンでは〜」「適用済み」「〜時点」)。
- 検査 (出力が空であること):
  ```bash
  grep -rn -E "このホスト|本機|このマシン|適用済み|実施済み|時点" --include="*.md" . --exclude-dir=add-task --exclude=AGENTS.md
  ```
- 手順と実際の環境がずれていないかは `omarchy-setup/files/status.sh` で確かめる (すべて ok)。
- コミットメッセージは日本語で、本文に「何を / なぜ」を書く。署名 (Co-Authored-By など) は付けない。
- 生の URL を表の中に置かない (`[owner/repo](https://...)` の形にする)。
