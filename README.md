# config — Omarchy 設定ナレッジベース

このリポジトリ (Omarchy / Hyprland) の設定を**別のホストに適用するための手順・設定値・知見**を記録する。
**新しいマシンを同じ環境にする**ために、できるだけ多くのナレッジを残すことが目的。

## 構成

```
~/dev/config/
├── AGENTS.md              # 引き継ぎ書 (エージェント/人間向けの作業ルールと現状)
├── README.md              # これ。目的と構成
├── CHANGELOG.md           # 索引: 日付・概要・詳細ファイルへのリンク
├── apps/                  # アプリ/機能ごとの詳細ナレッジ
│   ├── fcitx5-mozc.md     # 日本語入力 (Mozc) + fcitx5
│   ├── voxtype.md         # 音声入力(ディクテーション)
│   ├── hyprland-input.md  # キーボード配列 / タッチパッド
│   ├── display-scale.md   # 表示倍率 / Display パネルの11段スライダー
│   ├── bitwarden.md       # パスワードマネージャ (デスクトップ + CLI)
│   ├── discord.md         # チャット (公式クライアント)
│   ├── omarchy-agent.md   # 既定エージェントの選択 (未設定)
│   ├── github-ssh.md      # GitHub SSH のホスト鍵登録と検証
│   ├── browser.md         # 使っているブラウザ (Chromium) と候補一覧
│   └── zed.md             # エディタ (Arch は CLI 名が zeditor)
├── setup/
│   └── new-host.md        # 新規ホストへの適用手順 (まとめ)
├── assets/                # 他ホストへコピーする実ファイル
│   ├── fcitx5-omarchy-theme/  # fcitx5 候補ウィンドウ (Omarchy テーマ追従のテンプレート + hook)
│   └── torohash.monitor/      # 改造した Display パネル (bar widget clone)
└── backups/               # 変更前の設定ファイル退避
```

## 使い方

- **このリポジトリの運用ルール・現状・未解決事項** → `AGENTS.md`
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
- 手順・コマンド・ハマりどころは `apps/<name>.md` に集約。
- 変更前ファイルは必要に応じて `backups/` に退避。
- `/usr/share/omarchy/` は **編集禁止**(参照のみ)。ユーザー設定は `~/.config/` 配下。
