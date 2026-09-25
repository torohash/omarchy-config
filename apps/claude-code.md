# Claude Code — オプトアウト設定

## 何をするか / なぜ

Claude Code が Anthropic や第三者のサービスへ送る**任意の送信**を止める。
会話そのもの(モデルとのやり取り)は止まらない。

| 環境変数 | 止めるもの |
|---------|-----------|
| `DISABLE_TELEMETRY=1` | 利用状況のメトリクス(遅延・信頼性・使い方。コード・プロンプト・パスは含まない) |
| `DISABLE_ERROR_REPORTING=1` | Claude Code 内部のエラー報告(第三者のエラー追跡サービスへ送られる) |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | 「How is Claude doing this session?」の評価アンケートと、その後の会話ログ共有の確認 |

出典: [Data usage (Claude Code Docs)](https://code.claude.com/docs/en/data-usage)

**入れないもの**(理由つき):

| 環境変数 | 入れない理由 |
|---------|-------------|
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | 上の3つをまとめて止めるが、範囲が広い。必要最低限でない通信をすべて止める |
| `DISABLE_FEEDBACK_COMMAND=1` | `/feedback` `/bug` `/share` 自体を消す。自分で実行しない限り何も送られないので残す |

**モデル学習への利用はアカウント単位の設定**で、ローカルでは変えられない。
[claude.ai/settings/data-privacy-controls](https://claude.ai/settings/data-privacy-controls) で切り替える。

## 管理方法: 手順書 (Nix では管理しない)

`~/.claude/settings.json` には **Omarchy のテーマ切替 (`theme`) と Claude Code 自身も書き込む**。
Nix の symlink にすると、書き込みで実ファイルに置き換わり、次の `home-manager switch` と消し合う。
そのため、`jq` で `env` キーにだけマージする手順にする(エージェントもこの手順で実行してよい)。

## 導入手順

```bash
f=~/.claude/settings.json
mkdir -p ~/.claude
[ -f "$f" ] || echo '{}' > "$f"
tmp=$(mktemp "$f.XXXXXX")
jq '.env = ((.env // {}) + {
  "DISABLE_TELEMETRY": "1",
  "DISABLE_ERROR_REPORTING": "1",
  "CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY": "1"
})' "$f" > "$tmp" && chmod 0644 "$tmp" && mv "$tmp" "$f"
```

- `theme` など他のキーはそのまま残る。何度実行しても結果は同じ。
- **起動中のセッションには効かない**。新しく起動した Claude Code から効く。

## 検証

```bash
jq '.env' ~/.claude/settings.json
# => {
#      "DISABLE_TELEMETRY": "1",
#      "DISABLE_ERROR_REPORTING": "1",
#      "CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY": "1"
#    }
jq '.theme' ~/.claude/settings.json   # => Omarchy が書いた値が残っている
```

## ハマりどころ

- **`DISABLE_TELEMETRY` は Remote Control も止める**: Remote Control が依存する feature flag の評価も無効になる。
  Remote Control を使うなら `DISABLE_TELEMETRY` を外す(`DISABLE_ERROR_REPORTING` は影響しない)。
- **シェルの環境変数ではなく `settings.json` の `env` に書く**: Omarchy のランチャーや herdr から起動しても効く。
  `.bashrc` に書くと、そのシェルから起動したときにしか効かない。

## 撤去

```bash
f=~/.claude/settings.json
tmp=$(mktemp "$f.XXXXXX")
jq 'del(.env.DISABLE_TELEMETRY, .env.DISABLE_ERROR_REPORTING, .env.CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY)
    | if .env == {} then del(.env) else . end' "$f" > "$tmp" && chmod 0644 "$tmp" && mv "$tmp" "$f"
```

## 参考

- [Data usage](https://code.claude.com/docs/en/data-usage)(テレメトリ・エラー報告・アンケートの説明)
- [Settings](https://code.claude.com/docs/en/settings)(`settings.json` の `env`)
