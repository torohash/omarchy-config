# herdr — ターミナルワークスペースマネージャ

Omarchy 4.0.4 に**同梱**されている。tmux 的なマルチプレクサで、AI コーディングエージェント
向けのペイン/タブ/ワークスペース管理機能を持つ。

- バイナリ: `/usr/bin/herdr` (例: v0.8.2)
- 公式: [herdr.dev](https://herdr.dev/)
- エージェント向けガイド: [agent-guide.md](https://herdr.dev/agent-guide.md) / [llms.txt](https://herdr.dev/llms.txt)
  (`herdr --skill` でも取得可)

## 設定ファイルの場所

| 用途 | パス |
|------|------|
| ユーザー設定 (編集する) | `~/.config/herdr/config.toml` |
| Omarchy のシード (参照のみ) | `/usr/share/omarchy/config/herdr/config.toml` |
| サーバーソケット | `~/.config/herdr/herdr.sock` |
| ログ | `~/.config/herdr/herdr-server.log` |

**`/usr/share/omarchy/` は編集禁止。** ユーザー側の `~/.config/herdr/config.toml` を編集する。

## 重要な前提: Omarchy 版は「tmux 互換」に総入れ替えされている

Omarchy のシード設定は、同梱の tmux 設定 (`/usr/share/omarchy/config/tmux/tmux.conf`) を
herdr に移植したもの。そのため **herdr 本体のデフォルトキーバインドとは大きく異なる**。

| 操作 | herdr 純正 | Omarchy 版 |
|------|-----------|-----------|
| prefix | `ctrl+b` | `ctrl+space` |
| detach | `prefix+q` | `prefix+d` |
| config 再読込 | `prefix+shift+r` | `prefix+q` |
| ペイン移動 | `prefix+h/j/k/l` | `ctrl+alt+矢印` |
| 横分割 | `prefix+minus` | `prefix+h` |
| タブ閉じ | `prefix+shift+x` | `prefix+k` |
| タブ名変更 | `prefix+shift+t` | `prefix+r` |
| サイドバー | `prefix+b` | `prefix+b` |

> **注意:** `ctrl+space` は fcitx5 の IME 切替キーと衝突する。Omarchy の既定のままだと
> herdr が先に奪って日本語入力に切り替えられない。

## よく使うコマンド

```bash
herdr                              # 起動 / 既存セッションにアタッチ
herdr --default-config             # herdr 純正デフォルト設定を出力 (比較用の神ツール)
herdr config check                 # ~/.config/herdr/config.toml を検証
herdr server reload-config         # 実行中サーバーに設定を反映
herdr config reset-keys            # カスタムキーを退避して本体デフォルトに戻す
herdr status                       # サーバー/クライアント状態
herdr server stop                  # サーバー停止

omarchy restart herdr              # 最新設定で再読込
omarchy-menu-herdr-keybindings     # 現在の解決済みキーバインドを対話表示
omarchy-menu-herdr-keybindings --print   # 同じものをテキスト出力 (差分確認に便利)
```

> herdr には「解決済みキーバインドを CLI で出す」コマンドが無いため、Omarchy が
> `herdr --default-config` と config を突き合わせて `omarchy-menu-herdr-keybindings` を用意している。

## キー構文のメモ

- `prefix+X` … prefix 必須。`ctrl+alt+n` のように書くと prefix 無しの直接キー。
- 修飾: `ctrl` `shift` `alt` `cmd`/`super`。特殊キー: `enter` `tab` `esc` `left/right/up/down`。
- 記号は**名前**で書く: `minus` `comma` `period` `ampersand` `plus` `backtick` など。
  - `period` は OK、`dot` は **不可** (`invalid keybinding` になる)。`,` や `.` も可。
- `comma`/`period` のような記号の prefix バインドは、端末や tmux によっては届かないことがある
  (herdr 純正デフォルトは ctrl+letter やファンクションキーを推奨)。

## 適用する設定

`~/.config/herdr/config.toml`:
- キーバインドは **herdr 純正デフォルト**を土台にする (`[keys]` セクションを全削除 → 本体 v2 キー)
- **左手だけで操作できる**ように、prefix と移動キーを変える:

| 操作 | キー | 純正の既定 |
|------|------|-----------|
| prefix | `alt+s` | `ctrl+b` |
| 前 / 次の workspace | `prefix+a` / `prefix+d` | (なし) |
| 前 / 次の agent | `prefix+shift+a` / `prefix+shift+d` | (なし) |
| workspace を閉じる | `prefix+shift+q` | `prefix+shift+d` |

```toml
[keys]
# Left-hand only: prefix is alt+s (no conflict with pi / Claude Code / bash / Hyprland).
prefix = "alt+s"

# Workspace move (WASD-like): prefix+a = previous / prefix+d = next
previous_workspace = "prefix+a"
next_workspace = "prefix+d"

# Agent move: prefix+shift+a = previous / prefix+shift+d = next
previous_agent = "prefix+shift+a"
next_agent = "prefix+shift+d"

# Close workspace moves off prefix+shift+d (the herdr default) to make room for agent move.
close_workspace = "prefix+shift+q"
```

**prefix を `alt+s` にする理由**: 左手の親指 + 薬指で押せて、次のどれとも衝突しない。

| 相手 | 調べた場所 | `alt+s` |
|------|-----------|---------|
| Pi | 本体同梱の `docs/keybindings.md` | 未使用 (`ctrl+英字` はほぼ全部使っている) |
| Claude Code | 公式 Interactive mode のショートカット一覧 | 未使用 (`ctrl+s` はプロンプトの一時退避) |
| bash (Omarchy の inputrc + fzf) | `bind -p` | 未使用 (fzf は `ctrl+r` `ctrl+t` `alt+c`) |
| Hyprland (Omarchy) | `hyprctl binds -j` の SUPER なし | 未使用 (Alt 系は `alt+tab` だけ) |
| fcitx5 | IME 切替 | `ctrl+space` なので別 |

不採用にした候補: `ctrl+b` (Claude Code のバックグラウンド実行・Pi のカーソル左)、
`ctrl+s` (Pi の設定保存・Claude Code のプロンプト退避)、`ctrl+a` (bash の行頭移動)、
`ctrl+g` (Pi / Claude Code の外部エディタ)、`ctrl+q` (衝突は少ないが小指 2 本で押しにくい)。

**移動キーを A / D にする理由**: prefix の S の両隣で、WASD と同じ「A = 前、D = 次」。
agent は Shift 付きで同じ並びにする。そのため純正の「workspace を閉じる」(`prefix+shift+d`) を
`prefix+shift+q` へ移す (閉じる系: pane = `x`、tab = `shift+x`、workspace = `shift+q`)。

`[theme]` `[ui]` などキー以外は Omarchy のまま (tmux 風の見た目)。

### 変更の経緯

1. 初期: Omarchy 版 (prefix `ctrl+space`, tmux 互換キー)。
2. prefix だけ `ctrl+b` に変更 (IME 衝突回避)。
3. 混乱が大きいので `herdr config reset-keys` で **全キーを純正へ**。
4. agent / workspace の移動キーだけ `,` `.` で追加 (当初は agent が Shift 無し)。
5. workspace と agent を入れ替え、workspace を `prefix+,` `.`、agent を `prefix+shift+,` `.` にする。
6. 左手だけで操作できるよう、prefix を `alt+s`、移動を `prefix+a` / `d` (Shift 付きで agent) にし、
   workspace を閉じるキーを `prefix+shift+q` に移す。

### 反映手順

```bash
herdr config check            # => config: ok
herdr server reload-config    # => {"status":"applied"}
omarchy-menu-herdr-keybindings --print   # 反映確認
```

### 元に戻す

```bash
# 純正化前の Omarchy 版へ戻す
cp ~/dev/config/backups/herdr-config.toml.omarchy-backup ~/.config/herdr/config.toml
herdr server reload-config
```

## ハマりどころ / 知見

- **Omarchy プラグインを更新すると設定が戻る**: `omarchy-refresh-herdr` は
  `/usr/share/omarchy/config/herdr/config.toml` をユーザー設定へ上書きコピーする。
  実行すると prefix が `ctrl+space` に戻り、`[keys]` も Omarchy 版になる。
  更新後はこのファイルの手順で再適用する。
- **prefix が IME と衝突**: `ctrl+space` を prefix にすると fcitx5 の IME 切替が効かない。
  prefix は `ctrl+space` 以外にする。
- **prefix 候補はエージェント CLI と突き合わせる**: Pi と Claude Code は `ctrl+英字` をほぼ全部使う。
  `ctrl+s` などは「Omarchy とは衝突しないが、端末の中のエージェントと衝突する」。
  変えるときは Pi の `docs/keybindings.md` と Claude Code の Interactive mode の一覧を確認する。
- **prefix のあとのキーは herdr 自身の割り当てとだけ突き合わせる**: `omarchy-menu-herdr-keybindings --print`
  の重複を見る (純正の `prefix+shift+d` = workspace を閉じる、のように既定が埋まっていることがある)。
  ```bash
  omarchy-menu-herdr-keybindings --print | awk -F'→' '{gsub(/ +$/,"",$1); print $1}' | sort | uniq -d   # 空であること
  ```
- **IME オン時の prefix 後の文字キー**: fcitx5 (Mozc) が有効な間は、prefix の後の `a` `d` などが
  Mozc の入力に取られてプレフィックスモードに届かない可能性がある。herdr の
  `switch_ascii_input_source_in_prefix` は **macOS/Windows 限定**。
  効かない場合は IME をオフにして操作する。
- **設定は自動保存・自動反映されない**: 編集後は `herdr server reload-config` を忘れずに。
- **キー確認は `herdr --default-config`**: 純正の既定値が全部コメント付きで出る。
