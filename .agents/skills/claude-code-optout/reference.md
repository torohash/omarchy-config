# Claude Code のオプトアウト — 理由・ハマりどころ

手順は [SKILL.md](SKILL.md)。出典: [Data usage (Claude Code Docs)](https://code.claude.com/docs/en/data-usage)。

## 止めるもの

- **メトリクス** (`DISABLE_TELEMETRY`): 遅延・信頼性・使い方。コード・プロンプト・ファイルパスは含まない。
- **エラー報告** (`DISABLE_ERROR_REPORTING`): Claude Code 内部のエラーとスタックトレース。第三者のエラー追跡サービスに送られる。
- **評価アンケート** (`CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY`): 「How is Claude doing this session?」と、
  その後の「会話ログを見てよいか」の確認。

会話そのもの (モデルとのやり取り) は止まらない。

## 入れないもの

| 環境変数 | 理由 |
|---------|------|
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | 上の 3 つをまとめて止めるが範囲が広い |
| `DISABLE_FEEDBACK_COMMAND` | `/feedback` `/bug` `/share` を消すだけ。自分で実行しない限り何も送られない |

## 管理方法: Nix ではなく jq のマージ

`~/.claude/settings.json` には Omarchy のテーマ切替 (`omarchy-theme-set-claude` が `theme` を書く) と
Claude Code 自身も書き込む。Nix の symlink にすると、書き込みで実ファイルに置き換わり、次の switch と消し合う。

## ハマりどころ

- **`DISABLE_TELEMETRY` は Remote Control も止める**: Remote Control (手元の Claude Code のセッションを
  claude.ai やスマホのアプリから操作する機能) が使う feature flag の判定も無効になる。
  Remote Control を使うなら `DISABLE_TELEMETRY` を外す (`DISABLE_ERROR_REPORTING` は影響しない)。
- **シェルの環境変数ではなく `settings.json` の `env` に書く**: Omarchy のランチャーや herdr から起動しても効く。
