# Zed — エディタ

**入れるもの: Zed Editor (Arch `extra/zed`) + Omazed (Omarchy テーマ同期)。**
Omarchy 経由で入れると、テーマ連携用の `omazed` と `theme-set` hook まで入る。

- 何をするツールか: GUI エディタ。CLI から `zed .` でカレントディレクトリを開ける。
- Omarchy の `omarchy install editor zed` が入れるもの:
  - `zed` (`extra`) … GUI + CLI
  - `omazed` … Omarchy の現テーマから Zed テーマ `Omazed` を生成し、
    `~/.config/omarchy/hooks/theme-set.d/omazed` に自動同期 hook を置く
  - 最後に `gtk-launch dev.zed.Zed` で Zed を起動する

## 手順

```bash
# 導入 (Omarchy メニュー相当のコマンド)
omarchy install editor zed

# エージェントの bash には TTY が無いので、代わりにこれを叩く (Omarchy メニューと同じ経路):
#   omarchy-launch-floating-terminal-with-presentation 'omarchy-install-editor-zed'
```

### `zed` コマンドを使えるようにする (必須)

Arch の `zed` パッケージは **CLI バイナリを `/usr/bin/zeditor` という名前でインストールする**。
`/usr/bin/zed` は ZFS の `zed` (ZFS Event Daemon, `zfs-utils` が提供) とファイル衝突するため、
Arch が意図的にリネームしている (Zed 公式の Linux パッケージ指針でも推奨)。

そのためインストール直後は `zed .` が `command not found` になる。ユーザー側で
シンボリックリンクを張る。

```bash
ln -s /usr/bin/zeditor ~/.local/bin/zed
```

- `~/.local/bin` は Omarchy が PATH に追加済み (`/usr/share/omarchy/default/bash/env-bootstrap`)。
- sudo 不要。`zeditor` は実行時に `/usr/lib/zed/zed-editor` (GUI 本体) を解決して起動するので、
  シンボリックリンク経由でも動く。

確認:

```bash
which zed        # => ~/.local/bin/zed
zed --version    # => Zed 1.18.1 – /usr/lib/zed/zed-editor
zed .            # カレントディレクトリを開く
```

## パッケージ構成 (名前がややこしい)

| パス | 中身 |
|------|------|
| `/usr/bin/zeditor` | CLI。`zed .` 相当を処理し、GUI 本体を呼ぶ |
| `/usr/lib/zed/zed-editor` | GUI 本体。単体では CLI オプションを受けない |
| `/usr/share/applications/dev.zed.Zed.desktop` | ランチャー。`TryExec=zeditor` / `Exec=zeditor %U` |

## ハマりどころ

- **`zed` が無いのはインストール失敗ではない**。CLI 名が `zeditor` なだけ。
- **Zed の GUI から CLI はインストールできない**。コマンドパレットの
  `cli: install cli binary` は Linux では「`~/.local/bin` を PATH に追加しろ」という
  警告を出すだけで終わる (実装が macOS 専用)。自分で symlink を張る。
- **PATH 順の罠**: Omarchy は `~/.local/bin` を PATH の**末尾**に足す
  (`PATH=...:/usr/bin:~/.local/bin`)。将来 `zfs-utils` を入れると `/usr/bin/zed`
  (ZFS Event Daemon) が先に見つかり、この shim は隠れる。そのときは `zeditor` を
  直接使うか、`~/.local/bin` を PATH の先頭に移す。
- デスクトップランチャーと `omarchy-launch-editor` は `zeditor` を見ているので影響なし。
  壊れるのは端末の `zed` だけ。
- Omazed が `~/.config/zed/settings.json` の `theme` を `Omazed` に合わせるのは
  **初回のみ** (マーカー `~/.local/share/omazed/initialized`)。以降 Omarchy テーマを
  変えても hook は `~/.config/zed/themes/omazed.json` を再生成するだけなので、
  Zed 側で別テーマを選ぶと追随しない。

## 撤去

```bash
rm ~/.local/bin/zed                            # shim だけ消す
omarchy pkg drop zed omazed                    # 本体 + テーマ同期
rm -rf ~/.config/zed ~/.local/share/omazed     # 設定・テーマ・初期化マーカー
rm -f ~/.config/omarchy/hooks/theme-set.d/omazed
```

## 参考

- [zed-industries/zed — Name conflict with zfs-utils (#12290)](https://github.com/zed-industries/zed/issues/12290)
- [NixOS/nixpkgs — zed-editor: rename zed binary to zeditor (#344193)](https://github.com/NixOS/nixpkgs/pull/344193)
- [Zed docs — Building Zed for Linux](https://zed.dev/docs/development/linux.md)
