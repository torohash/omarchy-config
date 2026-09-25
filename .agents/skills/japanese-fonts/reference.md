# 日本語フォント — 理由・仕組み・ハマりどころ

手順は [SKILL.md](SKILL.md)。

## 何が起きていたか

Noto CJK は 1 つのフォントに JP / KR / SC / TC / HK の字形を持つ。fontconfig はロケール (`LANG`) から
どれを優先するかを決めるが、`en_US` では日本語を優先しないので、漢字が **Noto Sans CJK KR** で描かれる。

```bash
fc-match "sans-serif:charset=76f4" family     # 「直」を描くフォント => Noto Sans CJK KR (直す前)
```

候補ウィンドウ (fcitx5) は skill `fcitx5-mozc` でフォントを直接 `Noto Sans CJK JP` にしている。この skill はそれ以外のアプリ用。

## HackGen Console NF

[yuru7/HackGen](https://github.com/yuru7/HackGen): 英字は Hack、日本語は源柔ゴシック (JP の字形)、Nerd Font のアイコン入り。
AUR の `ttf-hackgen` に一式が入る。他のホスト (nix-config) の ghostty / Zed でも同じフォントを使っている。

| 名前 | 全角 : 半角 |
|------|------------|
| `HackGen Console NF` | 2 : 1 (一般的) |
| `HackGen35 Console NF` | 5 : 3 (英字が広く読みやすい) |

## `omarchy font set` がすること

- 端末 (alacritty / kitty / ghostty / foot) のフォント名を書き換える (foot はサイズが 9 になる)
- **`~/.config/fontconfig/fonts.conf` を丸ごと上書きし**、`monospace` の先頭に指定したフォントを置く
  (Omarchy の shell = バー・メニュー、Qt アプリ、`monospace` を使うものすべてに効く)
- shell を再起動し、hook `font-set` を呼ぶ。ghostty / foot は開き直すまで古いフォントのまま
- ghostty / foot が起動中だと「開き直して」という通知を出そうとするが、`omarchy-notification-send` の Usage が表示されて通知が出ないことがある。
  フォントの切り替え自体は済んでいるので無視してよい (開いている端末は開き直す)

## sans-serif / serif の JP 優先 (`conf.d/50-cjk-jp.conf`)

- `fonts.conf` は `omarchy font set` が上書きするので、**`~/.config/fontconfig/conf.d/` に別ファイルで置く**。
- `<prefer>` は、先に書いたフォントほど優先される。英字のフォント (Liberation) を先に書き、その次に Noto CJK JP を置く。
  **CJK JP だけを書くと、英字まで Noto CJK JP の字形になる** (CJK JP が先頭に来るため)。
- `monospace` は書かない。`omarchy font set` が先頭を決め、HackGen が日本語を持っている。
- Omarchy の既定の英字フォントが変わったら、`<prefer>` の先頭のフォント名も合わせる。

## 確かめ方

設定を入れる前に効き目を試すなら、`XDG_CONFIG_HOME` を一時ディレクトリに向けて `fc-match` する
(ユーザーの fontconfig は `$XDG_CONFIG_HOME/fontconfig/` から読まれる)。
