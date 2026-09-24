# herdr — ターミナルワークスペースマネージャ

Omarchy 4.0.4 に**同梱**されている。tmux 的なマルチプレクサで、AI コーディングエージェント
向けのペイン/タブ/ワークスペース管理機能を持つ。

- バイナリ: `/usr/bin/herdr` (例: v0.8.2)
- 公式: https://herdr.dev/
- エージェント向けガイド: https://herdr.dev/agent-guide.md, https://herdr.dev/llms.txt
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

> **注意:** `ctrl+space` は fcitx5 の IME 切替キーと衝突する。Omarchy のまま使うと
> herdr が先に奪って日本語入力に切り替えられない。(このため本環境では純正に戻した)

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

## 本環境での設定 (最終形)

`~/.config/herdr/config.toml`:
- キーバインドは **herdr 純正デフォルト**に戻した (`[keys]` セクションを全削除 → 本体 v2 キー)
  - prefix は `ctrl+b`。これで `ctrl+space` が IME 用に空く。
- 追加で **agent / workspace の移動キー**を足している:

```toml
[keys]
# Agent move: prefix+, = previous agent / prefix+. = next agent
previous_agent = "prefix+comma"
next_agent = "prefix+period"

# Workspace move: prefix+shift+, = previous / prefix+shift+. = next
previous_workspace = "prefix+shift+comma"
next_workspace = "prefix+shift+period"
```

`[theme]` `[ui]` などキー以外は Omarchy のまま (tmux 風の見た目)。

### 変更の経緯

1. 初期: Omarchy 版 (prefix `ctrl+space`, tmux 互換キー)。
2. prefix だけ `ctrl+b` に変更 (IME 衝突回避)。
3. 混乱が大きいので `herdr config reset-keys` で **全キーを純正へ**。
4. agent / workspace の移動キーだけ `,` `.` で追加。

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
  prefix は `ctrl+b` (純正) のままにしておくのが安全。
- **IME オン時の記号 prefix**: fcitx5 が有効な間は `,`/`.` が `、`/`。` に化けて
  プレフィックスモードに届かないことがある。herdr には
  `switch_ascii_input_source_in_prefix` という対策設定があるが **macOS/Windows 限定**。
  効かない場合は IME をオフにして操作するか、`prefix+[` `]` など別キーにする。
- **設定は自動保存・自動反映されない**: 編集後は `herdr server reload-config` を忘れずに。
- **キー確認は `herdr --default-config`**: 純正の既定値が全部コメント付きで出る。
