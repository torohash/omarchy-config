# config — Omarchy 設定ナレッジベース

このマシン (Omarchy / Hyprland) に加えた設定変更と、その導入手順・知見を記録する。
**別のホストマシンに同じ環境を再現する**ために、できるだけ多くのナレッジを残すことが目的。

## 構成

```
~/dev/config/
├── README.md              # これ。目的と構成
├── CHANGELOG.md           # 索引: 日付・概要・詳細ファイルへのリンク
├── apps/                  # アプリ/機能ごとの詳細ナレッジ
│   ├── herdr.md           # ターミナルワークスペースマネージャ (Omarchy 同梱)
│   ├── fcitx5-mozc.md     # 日本語入力 (Mozc) + fcitx5
│   └── hyprland-input.md  # キーボード配列 / タッチパッド
├── setup/
│   └── new-host.md        # 新規ホストへの適用手順 (まとめ)
├── assets/                # 他ホストへコピーする実ファイル
│   └── omarchy-tokyo-night/   # fcitx5 classicui 自作テーマ一式
└── backups/               # 変更前の設定ファイル退避
```

## 使い方

- **何を変えたか知りたい** → `CHANGELOG.md`
- **あるアプリの入れ方・ハマりどころを知りたい** → `apps/<name>.md`
- **新しいマシンに一気に適用したい** → `setup/new-host.md`

## 環境の前提

- OS: Omarchy 4.0.4 (Arch ベース, BUILD_ID=4.0.4)
- WM: Hyprland (Lua 設定, `~/.config/hypr/`)
- Shell: Omarchy shell (Quickshell)
- テーマ: Tokyo Night
- パッケージ管理: `pacman` + AUR(`yay`)。**flatpak / snap は未導入**
- 特権: agent からは `sudo` の対話入力ができないため **`pkexec`** を使う

## 記録ルール

- `CHANGELOG.md` は **索引**。1行 = 1変更 + 詳細ファイルへのリンク。
- 実際の手順・コマンド・ハマりどころは `apps/<name>.md` に集約。
- 変更前ファイルは必要に応じて `backups/` に退避。
- `/usr/share/omarchy/` は **編集禁止**(参照のみ)。ユーザー設定は `~/.config/` 配下。
