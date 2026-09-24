# Hyprland input — キーボード配列 / タッチパッド

Hyprland の入力設定は Omarchy が Lua で管理している。ユーザー上書きは
`~/.config/hypr/input.lua` に書く (Omarchy 既定の後に読み込まれる)。

## 仕組み (Omarchy 既定)

`/usr/share/omarchy/default/hypr/input.lua` (参照のみ) が次を行う:

- `kb_layout` を **`/etc/vconsole.conf` の `XKBLAYOUT`** から取得 (無ければ `us`)。
  本機は `jp` だった。`localectl status` の `X11 Layout: jp` と一致。
- `kb_options = "compose:caps,shift:both_capslock_cancel"`
  … Caps Lock を **Compose キー**に。両 Shift 同時押しが本来の Caps Lock。
- 非ラテン配列のときだけ先頭に `us,` を足して `grp:alts_toggle` を付ける (本機は非該当)。
- タッチパッド既定: `natural_scroll=false`, `clickfinger_behavior=true`, `scroll_factor=0.4`。

## 上書きの書き方

`~/.config/hypr/input.lua` の末尾に `hl.config({...})` を書く。**`hl.config` は深くマージ**
されるので、指定したキーだけ上書きされ、他の Omarchy 既定は生き残る (検証済み)。

```lua
hl.config({
  input = {
    kb_layout = "us",
    touchpad = {
      natural_scroll = true,
    },
  },
})
```

**注意:** このユーザーファイル冒頭のコメント例は「Uncommented settings below replace
Omarchy's defaults.」とあるが、実際は *指定キーの上書き*。他の値
(`scroll_factor`,`clickfinger_behavior`,`sensitivity`,`repeat_rate` 等) は保持される。

## 反映と検証 (必須)

```bash
hyprctl reload            # => ok
hyprctl configerrors      # => 空 (エラーが消えるまで直す)
```

個別値の確認:

```bash
hyprctl getoption input:kb_layout
hyprctl getoption input:touchpad:natural_scroll
hyprctl getoption input:touchpad:scroll_factor
hyprctl getoption input:touchpad:clickfinger_behavior
hyprctl getoption input:sensitivity
hyprctl getoption input:repeat_rate
```

## 本環境での変更

| 項目 | Omarchy 既定 | 変更後 | 理由 |
|------|-------------|--------|------|
| `kb_layout` | `jp` (vconsole 由来) | `us` | US 配列として入力したい |
| `touchpad.natural_scroll` | `false` | `true` | スクロール方向を反転 (自然スクロール) |

反映確認済み:
`input:kb_layout=us`, `input:touchpad:natural_scroll=true`, 他は既定のまま。

## 元に戻す

```bash
omarchy refresh hyprland    # ~/.config/hypr/*.lua を既定に戻す (バックアップ自動作成)
```

または `~/.config/hypr/input.lua` に追加した `hl.config` ブロックを削除して `hyprctl reload`。

## 知見

- `natural_scroll=true` は「コンテンツが指に付いてくる」方向 (タッチスクリーン/macOS 風)。
  従来の逆が好みなら `false` (Omarchy 既定)。
- 物理キーボードが JIS なのに `us` にすると、印字と出力がずれる (`@` の位置など)。
  配列は物理キーボードに合わせる。
- `kb_layout` を変えても TTY の `localectl` は変わらない。TTY も揃えるなら
  `sudo localectl set-x11-keymap us` 等 (未実施)。
- `hyprland.md` (Omarchy スキル) の指示どおり、変更後は必ず `hyprctl reload` と
  `hyprctl configerrors` で検証する。
