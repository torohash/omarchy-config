# Zed — 理由・ハマりどころ

手順は [SKILL.md](SKILL.md)。

## 入れるもの

- `zed` (`extra`): GUI + CLI
- `omazed`: Omarchy の今のテーマから Zed のテーマ `Omazed` を作り、
  `~/.config/omarchy/hooks/theme-set.d/omazed` に同期用の hook を置く

`omarchy install editor zed` はこの 2 つを入れて `omazed setup` を実行し、Zed を起動する。
手順書では sudo が要るパッケージ導入だけを特権の操作に分けている。

## パッケージの構成

| パス | 中身 |
|------|------|
| `/usr/bin/zeditor` | CLI。`zed .` 相当を処理して GUI 本体を呼ぶ |
| `/usr/lib/zed/zed-editor` | GUI 本体。単体では CLI オプションを受けない |
| `/usr/share/applications/dev.zed.Zed.desktop` | ランチャー (`Exec=zeditor %U`) |

## フォント

`omarchy font set` が変えるのは端末 (alacritty / kitty / ghostty / foot) と fontconfig の monospace だけで、
Zed は `~/.config/zed/settings.json` の `buffer_font_family` (本文)・`ui_font_family` (UI)・`terminal.font_family`
(Zed の中の端末) でフォントを決める。指定が無いと Zed の既定のフォントになる。他のホスト (nix-config の `zed.nix`) と同じく
3 つとも HackGen Console NF にする。`settings.json` は Zed の設定画面なども書き換えるので、symlink にせず jq でキーを足す。

## ハマりどころ

- **`zed` が無いのはインストール失敗ではない**。`/usr/bin/zed` は ZFS Event Daemon (`zfs-utils`) と
  衝突するため、Arch が CLI を `zeditor` にリネームしている。
- **Zed の GUI から CLI は入れられない**。`cli: install cli binary` は Linux では警告を出すだけ。
- **PATH の順番**: Omarchy は `~/.local/bin` を PATH の末尾に足す。`zfs-utils` を入れると
  `/usr/bin/zed` が先に見つかる。そのときは `zeditor` を使う。
- ランチャーと `omarchy-launch-editor` は `zeditor` を見ているので影響しない。
- Omazed が `~/.config/zed/settings.json` の `theme` を `Omazed` にするのは初回だけ
  (マーカー `~/.local/share/omazed/initialized`)。Zed 側で別テーマを選ぶと追従しない。

## 参考

- [zed-industries/zed #12290 — Name conflict with zfs-utils](https://github.com/zed-industries/zed/issues/12290)
- [Zed docs — Linux](https://zed.dev/docs/development/linux.md)
