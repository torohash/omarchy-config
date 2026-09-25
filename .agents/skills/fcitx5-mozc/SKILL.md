---
name: fcitx5-mozc
description: 日本語入力を使えるようにする。Omarchy 標準の fcitx5 に Mozc を足して Ctrl+Space で切り替え、候補ウィンドウを Omarchy のテーマに追従する自作テーマ (日本語フォント) にする。日本語入力を導入・確認するとき、候補ウィンドウの見た目やフォントを直すときに使う。
metadata:
  privilege: sudo
  depends: none
---

# 日本語入力 (fcitx5 + Mozc)

Omarchy は fcitx5 を標準で入れている (systemd のユーザーサービス `omarchy-fcitx5.service`)。Mozc だけ足す。
候補ウィンドウは Omarchy のテンプレート機能で、`omarchy theme set` のたびに `colors.toml` の色から描き直す。
仕組み・デザインの比較・ハマりどころは [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
F=~/dev/config/.agents/skills/fcitx5-mozc/files
pacman -Q fcitx5-mozc >/dev/null \
  && grep -qx 'Name=mozc' ~/.config/fcitx5/profile \
  && cmp -s "$F/classicui.conf" ~/.config/fcitx5/conf/classicui.conf \
  && for t in "$F"/themed/*.tpl; do cmp -s "$t" ~/.config/omarchy/themed/"${t##*/}" || exit 1; done \
  && cmp -s "$F/hooks/fcitx5-theme" ~/.config/omarchy/hooks/theme-set.d/fcitx5-theme \
  && [ -f ~/.local/share/fcitx5/themes/omarchy/theme.conf ] \
  && echo "fcitx5-mozc: ok"
```

## 特権で行う操作

```bash
omarchy pkg add fcitx5-mozc
```

## 実行

1. fcitx5 を止めてから設定を書く (fcitx5 は終了時に設定を書き戻すので、動いている間に書くと上書きされる)。

   ```bash
   F=~/dev/config/.agents/skills/fcitx5-mozc/files
   B=~/.local/state/omarchy-config/backups; mkdir -p "$B" ~/.config/fcitx5/conf
   systemctl --user stop omarchy-fcitx5.service; pkill -x fcitx5 || true
   for f in profile conf/classicui.conf; do [ -f ~/.config/fcitx5/$f ] && cp ~/.config/fcitx5/$f "$B/fcitx5-${f##*/}.$(date +%s)"; done
   cp "$F/profile" ~/.config/fcitx5/profile
   cp "$F/classicui.conf" ~/.config/fcitx5/conf/classicui.conf
   systemctl --user start omarchy-fcitx5.service
   ```

2. 候補ウィンドウのテンプレートと theme-set hook を置き、今のテーマで描画する。

   ```bash
   mkdir -p ~/.config/omarchy/themed
   cp "$F"/themed/*.tpl ~/.config/omarchy/themed/
   omarchy hook install theme-set "$F/hooks/fcitx5-theme"
   omarchy theme refresh        # テンプレートを描画し、hook が ~/.local/share/fcitx5/themes/omarchy/ に置く
   ```

## 検証

```bash
fcitx5-remote -n                                   # => keyboard-us または mozc (fcitx5 が動いている)
gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller \
  --method org.fcitx.Fcitx.Controller1.FullInputMethodGroupInfo "Default" | grep -o "'mozc'" | head -1   # => 'mozc'
grep NormalColor ~/.local/share/fcitx5/themes/omarchy/theme.conf     # => 今のテーマの foreground の色
fc-match "Noto Sans CJK JP:charset=76f4"                             # => "Noto Sans CJK JP"
```

`Ctrl+Space` で日本語と英数が切り替わる。候補ウィンドウの見た目を撮って確かめる方法は reference.md。

## 元に戻す

```bash
omarchy pkg drop fcitx5-mozc
rm -f ~/.config/fcitx5/profile ~/.config/fcitx5/conf/classicui.conf
rm -f ~/.config/omarchy/themed/fcitx5-*.tpl ~/.config/omarchy/hooks/theme-set.d/fcitx5-theme
rm -rf ~/.local/share/fcitx5/themes/omarchy
omarchy restart xcompose
```
