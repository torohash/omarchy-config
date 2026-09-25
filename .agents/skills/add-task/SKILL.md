---
name: add-task
description: Omarchy 環境構築リポジトリ (~/dev/config) に、新しい作業 skill を追加する・既存の作業 skill を書き直すときの書式とルール。「〜の導入手順を追加して」「この設定を手順化して」「skill にまとめて」と頼まれたときに使う。
---

# 作業 skill の追加・書き直し

このリポジトリの作業は **1 作業 = 1 skill** (`.agents/skills/<name>/`) で書く。
メインの手順書 `omarchy-setup` が各作業を順番に参照する。

## 置き場所と構成

```
.agents/skills/<name>/
├── SKILL.md       # 手順だけ: 確認 → 実行 → 検証 → 元に戻す (下のテンプレート)
├── reference.md   # 理由・比較した選択肢・経緯・ハマりどころ (手順は書かない)
└── files/         # 配る実ファイル (設定・テンプレート・hook など)。無ければ作らない
```

- `.claude/skills` は `.agents/skills` への symlink。Claude Code と Pi の両方が同じファイルを読む。
- `<name>` は英小文字・数字・ハイフン (64 文字以内)。`name:` と同じにする。

## 書くときのルール

1. **状態を書かない**。「このマシンでは〜だった」「適用済み」「(日付) 時点」は書かない。
   書くのは **何をするか / なぜ / どこでハマるか / どう検証するか** だけ。
   例外: Omarchy 側の前提 (「Omarchy 標準で fcitx5 が入っている」) は書いてよい。
2. **何度実行しても同じ結果になるように書く**。最初に「すでに済んでいるか」を確認し、
   済んでいれば実行を飛ばして検証だけ行う。途中まで済んでいる環境でも壊さない。
3. **コマンドは実際に動いたものをそのまま書く**。検証には**期待される出力**を書く。
4. **インストールは Omarchy 経由**: `omarchy pkg add` / `omarchy pkg aur add` / `omarchy install ...` /
   `omarchy webapp ...` / `mise use -g`。素の `pacman -S` や `pkexec pacman` は書かない。
   入れる前に、Omarchy が最初から入れていないか確認する
   (`/usr/share/omarchy/install/omarchy-base.packages`、`install/user/mise.sh`)。
5. **sudo が要る操作は `## 特権で行う操作` に集める**。メインの手順書がこれを 1 つの端末にまとめて
   実行し、パスワード入力を 1 回で済ませる。個々の skill で端末を開かない。
6. **ユーザーにしかできない操作** (ブラウザでのログイン等) は `## ユーザーに頼む操作` に書く。
7. **変更前に現在の値を確認する**。上書きするファイルは `~/.local/state/omarchy-config/backups/` に
   退避してから書く (リポジトリには置かない)。
8. 経緯・比較・ハマりどころは `reference.md` に書き、SKILL.md から 1 行でリンクする。
9. 追加・名前変更したら `omarchy-setup` の作業一覧も更新する。

## SKILL.md のテンプレート

````markdown
---
name: <name>
description: <何をするか>。<いつ使うか (「〜して」と頼まれたとき、〜を直すとき)>。
metadata:
  privilege: none        # none / sudo (特権で行う操作がある) / user (ユーザーに頼む操作がある)
  depends: <先に済ませる skill 名 (無ければ none)>
---

# <作業名>

<1〜3 行: 何をするか。なぜ必要か。詳細は [reference.md](reference.md)。>

## 確認 (済んでいれば「実行」を飛ばす)

```bash
<済んでいれば成功 (exit 0) するコマンド>
```

## ユーザーに頼む操作        <!-- 無ければ節ごと消す -->

## 特権で行う操作            <!-- 無ければ節ごと消す -->

```bash
omarchy pkg add <pkg>
```

## 実行

1. <手順>

```bash
<コマンド>
```

## 検証

```bash
<コマンド>
# => <期待される出力>
```

## 元に戻す

```bash
<コマンド>
```
````

## 書き終えたら

- 検索で状態の記述が残っていないか確認する:
  ```bash
  grep -rn -E "このホスト|本機|このマシン|適用済み|実施済み|時点" .agents/skills/ --exclude-dir=add-task
  ```
- 「確認」のコマンドを実際に実行し、済んでいる環境で成功すること、済んでいない要素があれば失敗することを確かめる。
