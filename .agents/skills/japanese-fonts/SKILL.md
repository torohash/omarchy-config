---
name: japanese-fonts
description: 日本語の表示を整える。端末とシステムの等幅フォントを HackGen Console NF (日本語入りの等幅フォント) にし、sans-serif / serif の漢字を韓国語版ではなく日本語版の字形 (Noto CJK JP) にする。漢字が中国語・韓国語っぽい字形で表示されるとき、端末のフォントを HackGen にしたいときに使う。
metadata:
  privilege: sudo
  depends: none
---

# 日本語フォント

ロケールが `en_US` だと、fontconfig は漢字を Noto CJK **KR** (韓国語版の字形) で描く (「直」「骨」などの形が違う)。
等幅は `omarchy font set` で HackGen Console NF (日本語の字形入り) にし、sans-serif / serif は漢字だけ Noto CJK JP を優先する。
理由とハマりどころは [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
fc-list : family | grep -qx 'HackGen Console NF' \
  && [ "$(omarchy font current)" = "HackGen Console NF" ] \
  && cmp -s ~/dev/config/.agents/skills/japanese-fonts/files/50-cjk-jp.conf ~/.config/fontconfig/conf.d/50-cjk-jp.conf \
  && echo "japanese-fonts: ok"
```

## 特権で行う操作

```bash
omarchy pkg aur add ttf-hackgen
```

## 実行

```bash
# 等幅: 端末 (alacritty / kitty / ghostty / foot) と fontconfig の monospace をまとめて変え、shell を再起動する
omarchy font set "HackGen Console NF"

# sans-serif / serif の漢字を JP 版に (fonts.conf は omarchy font set が上書きするので conf.d に置く)
mkdir -p ~/.config/fontconfig/conf.d
cp ~/dev/config/.agents/skills/japanese-fonts/files/50-cjk-jp.conf ~/.config/fontconfig/conf.d/50-cjk-jp.conf
```

開いている端末・ブラウザ・アプリは、開き直すと新しいフォントになる。

## 検証

```bash
omarchy font current                                   # => HackGen Console NF
for f in monospace sans-serif serif; do
  printf '%-11s latin=%-20s kanji=%s\n' "$f" \
    "$(fc-match "$f" family | cut -d, -f1)" "$(fc-match "$f:charset=76f4" family | cut -d, -f1)"
done
# => monospace   latin=HackGen Console NF   kanji=HackGen Console NF
#    sans-serif  latin=Liberation Sans      kanji=Noto Sans CJK JP
#    serif       latin=Liberation Serif     kanji=Noto Serif CJK JP
```

## 元に戻す

```bash
rm ~/.config/fontconfig/conf.d/50-cjk-jp.conf
omarchy font set "JetBrainsMono Nerd Font"            # Omarchy の既定に戻す
omarchy pkg drop ttf-hackgen
```
