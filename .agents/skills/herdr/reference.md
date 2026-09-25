# herdr — 理由・経緯・ハマりどころ

手順は [SKILL.md](SKILL.md)。ここには手順を書かない。

## herdr とは

Omarchy に同梱のターミナルマルチプレクサ (tmux 的)。AI コーディングエージェント向けの
pane / tab / workspace 管理機能を持つ。

- バイナリ: `/usr/bin/herdr`
- 公式: [herdr.dev](https://herdr.dev/) / エージェント向けガイド: [agent-guide.md](https://herdr.dev/agent-guide.md)
  (`herdr --skill` でも取得できる)

| 用途 | パス |
|------|------|
| ユーザー設定 (編集する) | `~/.config/herdr/config.toml` |
| Omarchy のシード (読むだけ) | `/usr/share/omarchy/config/herdr/config.toml` |
| サーバーソケット / ログ | `~/.config/herdr/herdr.sock` / `~/.config/herdr/herdr-server.log` |

## Omarchy 版は tmux 互換に総入れ替えされている

Omarchy のシードは同梱の tmux 設定を herdr に移植したもの。herdr 純正の既定とは大きく違う。

| 操作 | herdr 純正 | Omarchy 版 |
|------|-----------|-----------|
| prefix | `ctrl+b` | `ctrl+space` |
| detach | `prefix+q` | `prefix+d` |
| config 再読込 | `prefix+shift+r` | `prefix+q` |
| pane 移動 | `prefix+h/j/k/l` | `ctrl+alt+矢印` |
| 横分割 | `prefix+minus` | `prefix+h` |
| tab を閉じる | `prefix+shift+x` | `prefix+k` |
| workspace を閉じる | `prefix+shift+d` | `prefix+shift+k` |

`ctrl+space` は fcitx5 の IME 切替と衝突し、herdr が先に奪って日本語入力に切り替えられない。
混乱が大きいので、キーは純正を土台にして必要な分だけ変える。`[theme]` `[ui]` などキー以外は Omarchy のまま。

## prefix を `alt+s` にする理由

左手の親指 + 薬指で押せて、次のどれとも衝突しない。

| 相手 | 調べた場所 | `alt+s` |
|------|-----------|---------|
| Pi | 本体同梱の `docs/keybindings.md` | 未使用 (`ctrl+英字` はほぼ全部使っている) |
| Claude Code | 公式 Interactive mode のショートカット一覧 | 未使用 |
| bash (Omarchy の inputrc + fzf) | `bind -p` | 未使用 (fzf は `ctrl+r` `ctrl+t` `alt+c`) |
| Hyprland (Omarchy) | `hyprctl binds -j` の SUPER なし | 未使用 (Alt 系は `alt+tab` だけ) |
| fcitx5 | IME 切替 | `ctrl+space` なので別 |

不採用にした候補:

| 候補 | 理由 |
|------|------|
| `ctrl+b` (純正) | Claude Code のバックグラウンド実行、Pi のカーソル左 |
| `ctrl+s` | Pi のモデル・thinking の保存、Claude Code のプロンプト一時退避 |
| `ctrl+a` | bash の行頭移動 |
| `ctrl+g` | Pi / Claude Code の外部エディタ |
| `ctrl+q` | 衝突は少ないが、小指 2 本で押しにくい |

## 移動キーを A / D にする理由

prefix の S の両隣で、WASD と同じ「A = 前、D = 次」。agent は Shift 付きで同じ並び。
純正の「workspace を閉じる」(`prefix+shift+d`) と重なるので `prefix+shift+q` へ移す
(閉じる系: pane = `x`、tab = `shift+x`、workspace = `shift+q`)。

workspace・tab・pane を 1:1:1 で使っていると、`prefix+x` (pane を閉じる) で全部が消えるので、
workspace を閉じるキーを直接使う場面は少ない。

## 経緯

1. Omarchy 版 (prefix `ctrl+space`、tmux 互換キー)。
2. prefix だけ `ctrl+b` に変更 (IME 衝突回避)。
3. 混乱が大きいので `herdr config reset-keys` で全キーを純正へ。
4. agent / workspace の移動キーを `,` `.` で追加。
5. workspace と agent を入れ替え、よく使う workspace 移動を Shift 無しにする。
6. 左手だけで操作できるよう、prefix を `alt+s`、移動を A / D にする。

## ハマりどころ

- **`omarchy refresh herdr` で設定が戻る**: Omarchy のシードでユーザー設定を上書きする
  (prefix が `ctrl+space` に戻る)。実行したら SKILL.md をもう一度実行する。
- **prefix の候補はエージェント CLI と突き合わせる**: Pi と Claude Code は `ctrl+英字` をほぼ全部使う。
  「Omarchy とは衝突しないが、端末の中のエージェントと衝突する」キーが多い。
- **prefix のあとのキーは herdr 自身の割り当てと突き合わせる**: 純正でも埋まっているキーがある
  (`prefix+shift+d` = workspace を閉じる)。`omarchy-menu-herdr-keybindings --print` の重複を見る。
- **IME オン中は prefix のあとの文字キーが Mozc に取られる**: `a` `d` などがプレフィックスモードに届かない。
  herdr の `switch_ascii_input_source_in_prefix` は macOS / Windows 限定。
  Hyprland の横取りしない割り当てで prefix と同時に IME をオフにする案もあるが、
  操作後に IME がオフのまま残るので入れない。IME をオフにして操作する。
- **設定は自動で反映されない**: 編集後は `herdr server reload-config`。
- **キー構文**: 記号は名前で書く (`minus` `comma` `period` など。`dot` は不可)。
  herdr には解決済みのキーを出すコマンドが無いため、Omarchy が `omarchy-menu-herdr-keybindings` を用意している。

## よく使うコマンド

```bash
herdr --default-config                     # 純正の既定値 (コメント付き)
herdr config check                         # 設定の検証
herdr server reload-config                 # 実行中のサーバーに反映
herdr config reset-keys                    # [keys] を退避して純正に戻す
omarchy-menu-herdr-keybindings --print     # 解決済みのキー割り当て
```
