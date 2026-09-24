# エージェント — 既定エージェントの選択

**入れるもの / 設定するもの: なし。** 既定エージェントは選ばない(Omarchy も勝手には選ばない)。

## 記録しておくこと

- 設定するには: `omarchy default agent <pi|claude|codex|...>`
  → `~/.config/omarchy/defaults/agent` に1語書かれる。
- 起動: `omarchy agent` / `omarchy agent prompt "..."`(未設定だと選び方を案内して終了する)。
- **スキルは何もしなくてよい**: Omarchy 同梱の `/usr/share/omarchy/default/agents/skills/`
  がインストール時に各エージェントの skills ディレクトリへ symlink される
  (`omarchy update` で中身も更新される)。自分用スキルは同じディレクトリに別名で足す。

## 検証

```bash
omarchy default agent      # => 設定した名前 (未設定なら無出力)
omarchy agent              # => 既定エージェントが起動
```
