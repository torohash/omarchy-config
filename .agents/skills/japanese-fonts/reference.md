# 日本語フォント — 理由・仕組み・ハマりどころ

手順は [SKILL.md](SKILL.md)。

## 何が起きていたか

Noto CJK は 1 つのフォントに JP / KR / SC / TC / HK の字形を持つ。fontconfig はロケール (`LANG`) から
どれを優先するかを決めるが、`en_US` では日本語を優先しないので、漢字が **Noto Sans CJK KR** で描かれる。

```bash
fc-match "sans-serif:charset=76f4" family     # 「直」を描くフォント => Noto Sans CJK KR (直す前)
```

候補ウィンドウ (fcitx5) は skill `fcitx5-mozc` でフォントを直接 `Noto Sans CJK JP` にしている。この skill はそれ以外のアプリ用。

`50-cjk-jp.conf` で sans-serif / serif は直ったが、それ以外の経路では KR / SC / TC がまだ選ばれていた (下の「JP だけにする」)。

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

## JP だけにする (`conf.d/51-cjk-jp-only.conf`)

`50-cjk-jp.conf` は `sans-serif` / `serif` を頼まれたときにしか効かない。それ以外の経路で JP 以外の字形が選ばれていた。

| 経路 | 選ばれていたもの |
|------|------------------|
| GTK の UI フォント `Adwaita Sans` (Chrome のタブ・アドレスバー・メニュー、GTK アプリ) | KR (「社」「神」「祝」の偏が「示」) |
| ページの `lang="zh"` / `"zh-TW"` / `"ko"` | SC / TC / KR |
| CSS の `SimHei` / `黑体` / `SimSun` / `宋体` / `PMingLiU` (`65-nonlatin.conf` の別名で Noto CJK に置き換わる) | SC / TC |
| CSS で `"Noto Sans CJK SC"` などを名指し | SC / TC / KR |

- `Adwaita Sans` は `60-latin.conf` の別名で `system-ui` の候補を引き継ぎ、`65-nonlatin.conf` がその候補に韓国語用の
  `Noto Sans CJK KR` を入れている。ロケールが `en` なので JP を優先する手がかりが無く、KR が選ばれる。
- 別名の順番を足して直すと経路ごとの対処になるので、`<selectfont><rejectfont>` で SC / TC / KR / HK を fontconfig から隠す。
  フォントのパッケージには触らない。
- **`<glob>` で弾かない**。Noto CJK は JP と同じ `.ttc` に全地域の字形が入っているので、ファイルごと JP まで消える。
  ファミリー名の `<pattern>` で弾く。
- JP の字形にもハングルは入っているので、韓国語は読める。中国語・韓国語のページは日本式の字形になる。
- font-family の無いページや `system-ui` の漢字は、Noto Sans CJK JP か HackGen (どちらも JP の字形) になる。
- サイトが Web フォント (例: Google Fonts の `Noto Sans SC`) を配っている場合は fontconfig を通らないので直らない。

Chrome がどのフォントで描いたかは、DevTools Protocol の `CSS.getPlatformFontsForNode` で文字ごとに分かる。

## 確かめ方

設定を入れる前に効き目を試すなら、`XDG_CONFIG_HOME` を一時ディレクトリに向けて `fc-match` する
(ユーザーの fontconfig は `$XDG_CONFIG_HOME/fontconfig/` から読まれる)。
