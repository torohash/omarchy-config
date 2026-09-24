# AGENTS.md — このディレクトリの引き継ぎ書

これは **Omarchy マシンの設定変更ナレッジベース**。人間にもエージェントにも読めるように書いてある。

---

## 目的

1. **このマシンに何をしたか / なぜそうしたかを残す**(再現性・引き継ぎのため)
2. **別のホストマシンで同じ作業をまとめて再現できるようにする**

## 非ゴール

- Omarchy 本体の開発・改造ではない(→ `omarchy dev link` 系はスコープ外)
- `/usr/share/omarchy/` の編集(パッケージ管理下。**読むのは自由**)

---

## 前提環境(このマシン)

| 項目 | 値 |
|------|-----|
| OS | Omarchy 4.0.4 (Arch ベース) |
| WM | Hyprland(Lua 設定 `~/.config/hypr/`) |
| Shell | Omarchy shell(Quickshell) |
| テーマ | Tokyo Night / accent `#7aa2f7` |
| パッケージ | pacman + AUR(`yay`)。**flatpak / snap は使わない** |
| 特権 | 端末あり → `sudo` / エージェント → `pkexec` |

---

## ディレクトリ構成と役割

```
~/dev/config/
├── AGENTS.md              # ← これ。引き継ぎ書
├── README.md              # 人間向けの概要
├── CHANGELOG.md           # 索引: 日付 / 変更 / 対象 / 詳細リンク
├── apps/                  # アプリ・機能ごとの詳細ナレッジ
│   ├── herdr.md           # ターミナルワークスペースマネージャ
│   ├── fcitx5-mozc.md     # 日本語入力 (Mozc) + 候補ウィンドウのテーマ
│   ├── voxtype.md         # 音声入力(ディクテーション)
│   ├── hyprland-input.md  # キーボード配列 / タッチパッド
│   ├── display-scale.md   # 表示倍率 / Display パネルの11段スライダー
│   └── bitwarden.md       # パスワードマネージャ (デスクトップ + CLI)
├── setup/
│   └── new-host.md        # 新規ホストへの適用手順(これをなぞれば再現できる)
├── assets/                # 他ホストへコピーする実ファイル
│   ├── omarchy-tokyo-night/   # fcitx5 classicui 自作テーマ一式
│   └── torohash.monitor/      # 改造した Display パネル (bar widget clone)
└── backups/               # 変更前の設定ファイル退避
```

---

## 記録ルール(**これがこのリポジトリの肝**)

### 1. `CHANGELOG.md` は索引
- **1行 = 1変更**。日付 / 変更 / 対象 / 詳細ファイルへのリンク。
- 新しいものを上に積む。
- **決定事項も書く**(例:「既製テーマを比較したが自作を採用」)。後で「なぜこうなってるか」が追えるように。
- 詳細(手順・ハマりどころ)は書かない。`apps/` に書く。

### 2. `apps/<name>.md` は詳細ナレッジ
1アプリ1ファイル。以下を必ず含める:
- 何をするツールか / なぜ入れたか
- **導入手順(コマンドそのまま)**
- **ハマりどころ**(実際に踏んだ罠。最重要)
- 検証コマンドと**実際の結果**
- 撤去方法
- 参考リンク

### 3. `assets/` は「配る実ファイル」
設定ファイルの中身だけでなく、**テーマやアイコンなど実ファイルはここにコピー**しておく。
他ホストでは `cp -r` するだけで済む。

### 4. `backups/` は変更前の退避
`omarchy-refresh-*` などで戻せるものもあるが、独自変更はここに残す。

### 5. Markdown の書き方
- **生 URL を表の中に置かない**(レンダラでリンクにならず、末尾の `|` を拾われる)。
  `[owner/repo](https://...)` の形にする。
- コマンドは実際に動いたものをそのまま書く(この書き方で `setup/new-host.md` をなぞれば再現できる)。

---

## 作業の進め方(エージェント向け)

1. **Omarchy スキルを先に読む**(ハーネスの `skills/omarchy/SKILL.md` と `hyprland.md` 等)。
   `~/.config/hypr/` や `~/.config/omarchy/` を触るなら必須。
2. **現状確認 → バックアップ**。設定を書く前に `cat` / `hyprctl getoption` / `... --print` で現在値を見る。
3. **変更はユーザーに確認してから**。このリポジトリの運用では**勝手にインストールしない**方針。
4. **検証コマンドを必ず実行**して、結果をドキュメントに残す。
5. **`CHANGELOG.md` に1行 + `apps/` に詳細**を書く。必要なら `assets/` に実ファイルをコピー。
6. **git でコミット**(メッセージは日本語・本文に「何を/なぜ」)。

### 変更対象ごとの検証コマンド

```bash
# Hyprland 設定 (~/.config/hypr/*.lua)  ← 変更後は必須
hyprctl reload && hyprctl configerrors        # 空であること
hyprctl getoption input:kb_layout
hyprctl getoption input:touchpad:natural_scroll

# fcitx5 / Mozc / 候補テーマ
fcitx5-remote -n                              # 現在の IM
fcitx5-remote -t                              # ON/OFF トグル (state 1⇄2)
gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller \
  --method org.fcitx.Fcitx.Controller1.GetConfig "fcitx://config/addon/classicui"

# herdr
herdr config check                            # => config: ok
herdr server reload-config                    # => {"status":"applied"}
omarchy-menu-herdr-keybindings --print        # 解決済みキーバインド

# Voxtype
voxtype setup check                           # All checks passed
voxtype setup gpu --status                    # バックエンド
voxtype transcribe /tmp/sample.wav            # 喋らずにテスト
```

### 安全規則・落とし穴

- **`/usr/share/omarchy/` は絶対に編集しない**(`omarchy update` で消える)。読むのは自由。
- **特権**: 端末でパスワード入力できるなら `sudo`、エージェントなど端末が無い場合は `pkexec`。
  `omarchy pkg add` は自分で sudo するので `pkexec` で二重に包まない(素の `pkexec pacman -S` を使う)。
- **fcitx5 は終了時に設定を書き戻す**。手書きの設定を確実に読ませたいときは
  `pkill -9 -x fcitx5`(systemd の `Restart=always` で自動復帰)。
  `fcitx5-remote -r` では profile / classicui は読み直されない。
- **`omarchy-refresh-herdr` / `omarchy refresh hyprland` はユーザー設定を上書きする**。
  更新後に効かなくなったら `setup/new-host.md` を再実行。
- **Omarchy の既定は「そのままでは日本語で使えない」ものが多い**:
  - fcitx5 → Mozc が入っていない
  - Voxtype → `base.en` + `language="en"` の英語専用
  - herdr → prefix `ctrl+space` が IME と衝突

---

## 現在の状態(2026-09-25 時点)

| 領域 | 状態 | 詳細 |
|------|------|------|
| 日本語入力 | fcitx5 + Mozc、`Ctrl+Space` で切替 | [apps/fcitx5-mozc.md](apps/fcitx5-mozc.md) |
| 候補ウィンドウ | 自作 `omarchy-tokyo-night` テーマ(Mellow 設計 + Tokyo Night 配色) | 同上 |
| 音声入力 | Voxtype: `small`(実測で確定) / `ja` / VAD 有効 / GPU(Vulkan) | [apps/voxtype.md](apps/voxtype.md) |
| herdr | 純正キー + `prefix+,` `.` で agent/workspace 移動 | [apps/herdr.md](apps/herdr.md) |
| 入力デバイス | `kb_layout = us` / `natural_scroll = true` | [apps/hyprland-input.md](apps/hyprland-input.md) |
| 表示倍率 | `1.8x`(2880x1800 で選べるのは 1.667 / 1.8 / 1.875) | [apps/display-scale.md](apps/display-scale.md) |
| Display パネル | 自作 clone `torohash.monitor` に差し替え (SCALE が11段スライダー) | 同上 |
| Bitwarden | `bitwarden` + `bitwarden-cli` (`extra`)。`SUPER+SHIFT+/` (Passwords) は Bitwarden に差し替え済み | [apps/bitwarden.md](apps/bitwarden.md) |

## 別ホストへの適用

→ **[setup/new-host.md](setup/new-host.md)** を上から順に実行する。
`assets/omarchy-tokyo-night/` のコピーも含まれている。

---

## 保留・未検証(次に触る人へ)

| 項目 | 状況 |
|------|------|
| fcitx5 の起動時 IM | 終了時に `DefaultIM` を `mozc` に書き戻す癖があり、**次回ログイン時に日本語始まりになる可能性**。英数固定にするならログイン時 `fcitx5-remote -c` を実行する設定を足す(未実施・ユーザー判断待ち) |
| herdr `prefix+,` / `prefix+.` | IME オン中は `,`/`.` が `、`/`。` に化けて効かない可能性(未検証) |
| Caps Lock の IME 切替 | 検討したが **`Ctrl+Space` 運用で決着**。`keyd` は未導入 |
| タッチパッド | `natural_scroll` を反転して確定(好みが変わったら `~/.config/hypr/input.lua`) |
| classicui テーマ | 微調整は `~/.local/share/fcitx5/themes/omarchy-tokyo-night/theme.conf`。変更したら `assets/` にも同期 |
| Display パネル clone | `omarchy update` 後にパネルが元に戻っていたら `setup/new-host.md` の 5 を再実行。QML は hot-reload されないので必ず `omarchy restart shell` |
| Bitwarden の見た目 | 倍率 1.8 でも論理 875x600 で普通だが、`no_screen_share` により **スクショで検証できない**ため目視判断待ち。大きければ `--force-device-scale-factor=1` (`apps/bitwarden.md`) |

---

## よく使うコマンド

```bash
cd ~/dev/config && git log --oneline          # 変更履歴
git add -A && git commit -m "..."             # 記録

omarchy commands                              # Omarchy の全コマンド
omarchy theme current
hyprctl configerrors
fcitx5-remote -n && voxtype setup check && herdr config check
```
