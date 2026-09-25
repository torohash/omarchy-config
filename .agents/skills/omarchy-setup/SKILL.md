---
name: omarchy-setup
description: 新しい Omarchy マシンに、このリポジトリ (~/dev/config) の環境をまとめて構築するメインの手順書。各作業 skill を順番に確認・実行し、sudo はまとめて 1 回、ユーザーの操作はまとめて頼む。「セットアップして」「環境を構築して」「どこまで済んでいるか確認して」と頼まれたときに使う。
metadata:
  privilege: sudo
  depends: none
---

# Omarchy の環境構築 (メインの手順書)

各作業は 1 つずつ skill になっている。この手順書は **順番・まとめ方・全体の検証** だけを決め、
個々のコマンドは各 skill の SKILL.md に従う。作業の一覧と順番は [files/order.txt](files/order.txt)。

| skill | 区分 | 内容 |
|-------|------|------|
| `hyprland-input` | 必須 | キーボード配列 US、タッチパッドの自然スクロール |
| `fcitx5-mozc` | 必須 | 日本語入力 (Ctrl+Space) と、テーマに追従する候補ウィンドウ |
| `japanese-fonts` | 必須 | 等幅を HackGen Console NF に、漢字を日本語の字形に |
| `herdr` | 必須 | herdr のキーを左手だけで操作できるようにする (prefix `alt+s`) |
| `github` | 必須 | `gh auth login` の案内と GitHub の SSH ホスト鍵 |
| `claude-code-optout` | 必須 | Claude Code のテレメトリ等を止める |
| `nix-home-manager` | 必須 | Nix + Home Manager (Claude Code の CLAUDE.md、Pi のモデル設定・検索設定・自動圧縮) |
| `pi-packages` | 必須 | Pi の拡張 |
| `agent-photo-sync` | 必須 | スマホの写真を Pi / Claude Code で受け取る (拡張・MCP・ufw) |
| `display-scale` | 任意 | Display パネルの倍率スライダーと表示倍率 |
| `voxtype` | 任意 | 音声入力の日本語化 |
| `openwhispr` | 任意 | 会議の議事録 (話者の区別) と音声入力 |
| `chrome` / `bitwarden` / `discord` / `zed` / `turso` | 任意 | アプリ |

## 前提

- Omarchy がインストール済みで、デスクトップ (Hyprland) が動いている。
- このリポジトリが `~/dev/config` にある (公開リポジトリなので認証なしで取れる)。
  ```bash
  [ -d ~/dev/config ] || git clone https://github.com/torohash/omarchy-config ~/dev/config
  ```
- Omarchy スキル (`omarchy`) は Omarchy が各エージェントに入れている。設定を触る前に読む。

## 1. 状況を調べる

```bash
~/dev/config/.agents/skills/omarchy-setup/files/status.sh
# => skill ごとに ok / NG
```

すべて ok なら終わり。NG の skill だけを以降の対象にする。

## 2. 任意の作業をユーザーに選んでもらう

NG のうち「任意」の skill は、入れるかどうかをユーザーに聞く (まとめて 1 回聞く)。
「必須」はそのまま対象にする。

同じときに、対象の skill の「ユーザーに頼む操作」のうち **特権の操作の前に** と書かれたもの
(例: `agent-photo-sync` の、ufw で許可する LAN の確認) も聞いておく。

## 3. 特権の操作をまとめて実行する (パスワードは 1 回)

対象のうち `metadata.privilege: sudo` の skill について、「特権で行う操作」を 1 つの端末にまとめて実行する。
ユーザーには「フローティング端末が開くので、sudo のパスワードを 1 回入れてください」と伝える。

```bash
# 中身を見るだけ (ユーザーに見せてもよい)
~/dev/config/.agents/skills/omarchy-setup/files/run-privileged.sh --print <skill...>

# 実行: ユーザーが端末で終えるまで待つので、バックグラウンドで実行して完了を待つ
~/dev/config/.agents/skills/omarchy-setup/files/run-privileged.sh <skill...>
# => OK  (失敗した skill があれば FAILED <skill> の行が出る)
```

- エージェントの bash には TTY が無いので sudo を直接使えない。必ずこの端末を経由する。
- FAILED が出たら、その skill の reference.md のハマりどころを見て原因を調べる。ほかの skill は続けてよい。

## 4. ユーザーに頼む操作をまとめて案内する

対象の skill の「ユーザーに頼む操作」を集めて、まとめて案内する (例: `gh auth login`、Bitwarden のログイン、表示倍率の選択)。
後続の作業が待つもの (`github` の `gh auth login`) は、終わったと言われてから進める。

## 5. 各 skill を順番に実行する

order.txt の順に、対象の skill の SKILL.md に従う: **確認 → (NG なら) 実行 → 検証**。
特権の操作は手順 3 で済んでいるので、各 skill の「実行」から行う。

## 6. 全体を検証する

```bash
~/dev/config/.agents/skills/omarchy-setup/files/status.sh
# => 対象にした skill がすべて ok
```

NG が残れば、その skill の検証とハマりどころを見て直す。最後に、ユーザーに残っている操作
(ログイン、再ログインで反映されるもの) を伝える。

## 作業を追加するとき

skill `add-task` に従って skill を作り、`files/order.txt` と上の表に 1 行足す。
