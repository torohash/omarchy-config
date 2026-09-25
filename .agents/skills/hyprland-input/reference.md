# Hyprland input — 理由・仕組み・ハマりどころ

手順は [SKILL.md](SKILL.md)。

## Omarchy 既定の仕組み

`/usr/share/omarchy/default/hypr/input.lua` (読むだけ) が次を行う。

- `kb_layout` を `/etc/vconsole.conf` の `XKBLAYOUT` から取る (無ければ `us`)。`localectl status` の `X11 Layout` と一致する。
- `kb_options = "compose:caps,shift:both_capslock_cancel"`: Caps Lock は Compose キー。両 Shift 同時押しが本来の Caps Lock。
- 非ラテン配列のときだけ先頭に `us,` を足して `grp:alts_toggle` を付ける。
- タッチパッド既定: `natural_scroll=false`、`clickfinger_behavior=true`、`scroll_factor=0.4`。

## 上書きの仕組み

`~/.config/hypr/input.lua` は Omarchy 既定の後に読まれる。`hl.config` は**深くマージ**されるので、
指定したキーだけ変わり、`scroll_factor` などほかの既定は残る。
ユーザーファイル冒頭のコメントには「Uncommented settings below replace Omarchy's defaults.」とあるが、
実際は指定したキーの上書き。

## 理由

| 項目 | 設定値 | 理由 |
|------|--------|------|
| `kb_layout` | `us` | US 配列として入力したい (vconsole 由来だと `jp` になることがある) |
| `touchpad.natural_scroll` | `true` | コンテンツが指に付いてくる方向 (macOS / タッチスクリーン風) |

## ハマりどころ

- **物理キーボードが JIS なのに `us` にすると、印字と出力がずれる** (`@` の位置など)。配列は物理キーボードに合わせる。
- `kb_layout` を変えても TTY の配列は変わらない。TTY も揃えるなら `sudo localectl set-x11-keymap us`。
- 変更後は必ず `hyprctl reload` と `hyprctl configerrors` で検証する (Omarchy スキルの指示)。
- `omarchy refresh hyprland` で `~/.config/hypr/*.lua` が既定に戻る (バックアップは自動で作られる)。

## 個別値の確認

```bash
hyprctl getoption input:touchpad:scroll_factor
hyprctl getoption input:touchpad:clickfinger_behavior
hyprctl getoption input:sensitivity
hyprctl getoption input:repeat_rate
```
