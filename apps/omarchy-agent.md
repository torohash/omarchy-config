# Omarchy のエージェント設定の扱い (スキル / 既定エージェント / 使用量)

Omarchy が「グローバルなエージェント設定」をどう扱っているかのまとめ。
結論: **Omarchy が持つのは「スキル(共有プロンプト)」と「既定エージェントの選択」だけ**で、
各エージェント自身の設定ファイル (`~/.claude/` など) は所有しない。

## 1. スキル (共有プロンプト) はパッケージ側にあり、各エージェントへ symlink

本体は `/usr/share/omarchy/default/agents/skills/<name>/`(パッケージ所有・読み取り専用扱い)。
これを**各エージェントのスキルディレクトリに symlink** する:

```
~/.agents/skills/<name>        -> $OMARCHY_PATH/default/agents/skills/<name>
~/.claude/skills/<name>        -> 同
~/.codex/skills/<name>         -> 同
~/.pi/agent/skills/<name>      -> 同
```

- 同梱スキル: `omarchy`(Omarchy の操作・設定手順) と `diagnose-crash`(クラッシュ診断)
- symlink なので **`omarchy update` で中身が自動的に最新になる**。**ここを直接編集しない**
- 自分のスキルを足すときは、同じディレクトリに**別名**で置く(例 `~/.claude/skills/my-skill/`)。
  リポジトリ管理にしたいならこのリポジトリに置いて symlink する

作成しているのはマイグレーション (`/usr/share/omarchy/migrations/` の
`1786098807.sh` = omarchy スキル、`1786539345.sh` = diagnose-crash)。
つまり**新規ホストでは Omarchy を入れた時点で自動で張られる**。

## 2. 既定エージェント (キーバインド/メニューから起動するもの)

- 選択は `~/.config/omarchy/defaults/agent` に**1語だけ**書かれたファイル。
  ```bash
  omarchy default agent            # 現在の選択を表示 (未設定なら無言で終了)
  omarchy default agent pi         # 設定 (pi|omp|opencode|claude|codex|grok|...)
  ```
- **Omarchy は既定を勝手に選ばない**。未設定だと `omarchy agent` は
  「`omarchy default agent <name>` で選べ」と言って終了する。
- 起動: `omarchy agent` / `omarchy agent prompt "..."` / `omarchy agent --pick`。
  実行時は各エージェントの「確認を止める」フラグが自動で付く
  (例: `claude --permission-mode auto`, `codex --approve-for-me`, `gemini --yolo`)。
- `$HOME` から起動すると信頼確認が毎回出るため、`~/Work` があればそこで起動する。

## 3. 使用量 / クラッシュ

- `omarchy agent usage update` → `~/.local/state/omarchy/agents/usage/*.json`。
  bar の `omarchy.agents` ウィジェットが表示する。
  各エージェントの記録 (`~/.claude/projects`, `$CODEX_HOME` など) を**読むだけ**で、
  設定は書き換えない。`omarchy agent usage claude` / `codex` で個別取得。
- `omarchy-crash-watch.service` (user service) がプロセスのクラッシュを監視し、
  `omarchy agent crash` で `diagnose-crash` スキルを使った診断を起動できる。

## 4. Omarchy が所有しないもの (= 自分で管理するもの)

| 場所 | 中身 | 扱い |
|------|------|------|
| `~/.pi/agent/` | pi 本体の設定 (`settings.json`, `auth.json` など) | 自分で管理 |
| `~/.claude/`, `~/.codex/` | 各エージェントの設定・履歴 | 自分で管理 |
| `~/.config/mise/config.toml` | グローバル CLI (`node`, `gh`, `pi`, `codex` など) | 自分で管理 |
| `~/.config/omarchy/defaults/agent` | 既定エージェントの1語 | `omarchy default agent` 経由で |

「全エージェント共通の指示」を置きたい場合、Omarchy の流儀は
**スキル経由**(上記3ディレクトリに symlink / 自前スキルを追加)で、
各エージェント固有の設定ファイルはそれぞれの場所に置く。

## 検証 (期待される出力)

```bash
ls -l ~/.pi/agent/skills ~/.claude/skills ~/.codex/skills ~/.agents/skills
# => omarchy / diagnose-crash が $OMARCHY_PATH/default/agents/skills/... への symlink
omarchy default agent            # => 設定されていれば名前、未設定なら何も出ない
omarchy agent                    # => 既定エージェントが起動 (未設定ならエラー案内)
systemctl --user status omarchy-crash-watch.service   # => active
```

## 参考

- スキル本体: `/usr/share/omarchy/default/agents/skills/` (参照のみ)
- 起動ラッパ: `/usr/share/omarchy/bin/omarchy-agent`, `omarchy-default-agent`
- 使用量: `/usr/share/omarchy/bin/omarchy-agent-usage-update` ほか
