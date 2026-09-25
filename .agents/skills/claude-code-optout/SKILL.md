---
name: claude-code-optout
description: Claude Code のテレメトリ・エラー報告・評価アンケートを ~/.claude/settings.json の env でオプトアウトする (theme など他のキーは残す)。Claude Code の任意の送信を止めたい・確認したいときに使う。
metadata:
  privilege: none
  depends: none
---

# Claude Code のオプトアウト

`~/.claude/settings.json` の `env` にだけマージする。このファイルは Omarchy のテーマ切替 (`theme`) と
Claude Code 自身も書くので、上書きも symlink もしない。理由と入れない変数は [reference.md](reference.md)。

| 環境変数 | 止めるもの |
|---------|-----------|
| `DISABLE_TELEMETRY=1` | 利用状況のメトリクス |
| `DISABLE_ERROR_REPORTING=1` | エラー報告 (第三者のエラー追跡サービス宛て) |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | 評価アンケートと、その後の会話ログ共有の確認 |

## 確認 (済んでいれば「実行」を飛ばす)

```bash
jq -e '.env.DISABLE_TELEMETRY == "1" and .env.DISABLE_ERROR_REPORTING == "1"
       and .env.CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY == "1"' ~/.claude/settings.json >/dev/null 2>&1 \
  && echo "claude-code-optout: ok"
```

## 実行

```bash
f=~/.claude/settings.json
mkdir -p ~/.claude ~/.local/state/omarchy-config/backups
[ -f "$f" ] && cp "$f" ~/.local/state/omarchy-config/backups/claude-settings.json.$(date +%s) || echo '{}' > "$f"
tmp=$(mktemp "$f.XXXXXX")
jq '.env = ((.env // {}) + {
  "DISABLE_TELEMETRY": "1",
  "DISABLE_ERROR_REPORTING": "1",
  "CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY": "1"
})' "$f" > "$tmp" && chmod 0644 "$tmp" && mv "$tmp" "$f"
```

起動中の Claude Code には効かない。次に起動したものから効く。

## ユーザーに頼む操作

モデルの学習への利用はアカウント単位の設定で、ローカルでは変えられない。
[claude.ai/settings/data-privacy-controls](https://claude.ai/settings/data-privacy-controls) で確認してもらう。

## 検証

```bash
jq '.env' ~/.claude/settings.json
# => { "DISABLE_TELEMETRY": "1", "DISABLE_ERROR_REPORTING": "1", "CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY": "1" }
jq '.theme' ~/.claude/settings.json      # => Omarchy が書いた値が残っている
```

## 元に戻す

```bash
f=~/.claude/settings.json; tmp=$(mktemp "$f.XXXXXX")
jq 'del(.env.DISABLE_TELEMETRY, .env.DISABLE_ERROR_REPORTING, .env.CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY)
    | if .env == {} then del(.env) else . end' "$f" > "$tmp" && chmod 0644 "$tmp" && mv "$tmp" "$f"
```
