# AGENTS.md — このディレクトリの引き継ぎ書

これは **Omarchy マシンの設定変更ナレッジベース**。人間にもエージェントにも読めるように書いてある。

---

## 目的

1. **別のホストマシンで同じ作業をまとめて再現できるようにする**
2. **なぜその設定にしたかを残す**(採用理由・比較した選択肢)

## 非ゴール

- Omarchy 本体の開発・改造ではない(→ `omarchy dev link` 系はスコープ外)
- `/usr/share/omarchy/` の編集(パッケージ管理下。**読むのは自由**)

---

## 前提環境

| 項目 | 値 |
|------|-----|
| OS | Omarchy 4.0.4 (Arch ベース) |
| WM | Hyprland(Lua 設定 `~/.config/hypr/`) |
| Shell | Omarchy shell(Quickshell) |
| テーマ | Tokyo Night / accent `#7aa2f7` |
| パッケージ | pacman + AUR(`yay`)。**flatpak / snap は使わない** |
| 特権 | エージェントの bash に TTY は無い → sudo 不可。Omarchy 経由か floating terminal で |

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
│   ├── bitwarden.md       # パスワードマネージャ (デスクトップ + CLI)
│   ├── discord.md         # チャット (公式クライアント)
│   ├── omarchy-agent.md   # 既定エージェントの選択 (未設定)
│   ├── github-ssh.md      # GitHub SSH のホスト鍵登録と検証
│   ├── browser.md         # 使っているブラウザ (Chromium) と候補一覧
│   ├── turso.md           # Turso CLI (mise)
│   ├── nix.md             # Nix + Home Manager (nix-config との分担)
│   ├── zed.md             # エディタ (Arch は CLI 名が zeditor)
├── setup/
│   └── new-host.md        # 新規ホストへの適用手順(これをなぞれば再現できる)
├── assets/                # 他ホストへコピーする実ファイル
│   ├── omarchy-tokyo-night/   # fcitx5 classicui 自作テーマ一式
│   └── torohash.monitor/      # 改造した Display パネル (bar widget clone)
└── backups/               # 変更前の設定ファイル退避
```

---

## 作業前に必ず読むもの (Omarchy スキル)

**~/.config/hypr/ や ~/.config/omarchy/ を触る前に、必ず Omarchy スキルを読む。**
まだこのセッションで読んでいないなら、何よりも先に読むこと。読んでから作業を始める。

| ファイル | 中身 |
|--------|------|
| `/usr/share/omarchy/default/agents/skills/omarchy/SKILL.md` | 必須。Omarchy のコマンド体系・特権の使い分け・安全規則 |
| 同 `hyprland.md` | bindings / monitors / window rules / Hyprland 設定 |
| 同 `theming.md` / `plugins.md` / `capture.md` / `hooks.md` / `contributing.md` | テーマ / shell / 撮影 / hook / バグ報告 |

(`~/.pi/agent/skills/omarchy/` はこのディレクトリへの symlink。どちらを読んでも同じ)

このスキルが読めていないと実際にやらかす。実際に起きた事故:

- `omarchy pkg add` ではなく **`pkexec pacman -S` でインストール**してしまった
- **Omarchy に既にある手段(Web アプリ版 Discord)を確認せずネイティブを入れ、ランチャーを重複**させた
- スキルの指示(`omarchy plugin clone` で複製してから編集)に気づかず、
  `/usr/share/omarchy/` を直接編集しかけた

特に**インストール**は必ず「スキルの決定フレームワーク」に従う:
`omarchy pkg add` / `omarchy install ...` / `omarchy webapp ...` を使い、
権限が要る操作はユーザーの端末で実行してもらう。

---

## 記録ルール(**これがこのリポジトリの肝**)

### 0. 状態を書かない(最優先)

このリポジトリは**別ホストに同じ構成を作るための手順**。
だから「この機械が今どうなっているか」は**書かない**。書くのは
**何を入れるか / 何をするか / なぜそうするか / どこでハマるか / どう検証するか**だけ。

| NG(この機械の状態を述べている) | OK(何を入れるか・何をするか) |
|------------------------------|------------------------|
| 「このホストの選択: Chrome」 | 「入れるもの: Google Chrome」 |
| 「このマシンでは 1.8x にした」 | 「表示倍率を 1.8x にする」 |
| 「本機では `jp` だった」 | 「JIS 機なら `jp` になる」 |
| 「適用済み / 実施済み / 変更した」 | 「〜する」「〜にする」 |
| 「(2026-09-25 時点)」 | 日付を書かない |

- 例外: 「Omarchy 標準で `fcitx5` が導入済み」のように**対象が Omarchy 側**の前提は書いてよい
  (この機械の状態ではない)。
- 検査(残っていたら直す):

  ```bash
  # AGENTS.md 自身はこの表と検査コマンドを含むので除外する
  grep -rn -E "このホスト|本機|このマシン|適用済み|実施済み|時点" --include="*.md" --exclude=AGENTS.md .
  ```

### 1. `CHANGELOG.md` は索引
- **1行 = 1変更**。日付 / 変更 / 対象 / 詳細ファイルへのリンク。
- 新しいものを上に積む。
- **決定事項も書く**(例:「既製テーマを比較したが自作を採用」)。後で「なぜこうなってるか」が追えるように。
- 詳細(手順・ハマりどころ)は書かない。`apps/` に書く。

### 2. `apps/<name>.md` は詳細ナレッジ
1アプリ1ファイル。以下を必ず含める:
- 何をするツールか / なぜ入れるか
- **導入手順(コマンドそのまま)**
- **ハマりどころ**(最重要)
- 検証コマンドと**期待される出力**
- 撤去方法
- 参考リンク

### 3. `assets/` は「配る実ファイル」
設定ファイルの中身だけでなく、**テーマやアイコンなど実ファイルはここにコピー**しておく。
他ホストでは `cp -r` するだけで済む。

### 4. `backups/` は変更前の退避
上書きする前に元ファイルを退避する(戻すとき・差分を見るとき用)。
他のホストで使う実ファイルは `assets/` 側に置く。

### 5. Markdown の書き方
- **生 URL を表の中に置かない**(レンダラでリンクにならず、末尾の `|` を拾われる)。
  `[owner/repo](https://...)` の形にする。
- コマンドは実際に動いたものをそのまま書く(この書き方で `setup/new-host.md` をなぞれば再現できる)。

---

## 作業の進め方(エージェント向け)

1. **Omarchy スキルを先に読む** → 「作業前に必ず読むもの」の節を参照。
   harness の `~/.pi/agent/skills/omarchy/SKILL.md` と、
   必要なら `hyprland.md` 等のトピックガイド(`/usr/share/omarchy/default/agents/skills/omarchy/`)。
   未読なら**最初に読む**。読まずに設定を触らない。
2. **現状確認 → バックアップ**。設定を書く前に `cat` / `hyprctl getoption` / `... --print` で現在値を見る。
3. **変更はユーザーに確認してから**。このリポジトリの運用では**勝手にインストールしない**方針。
   入れるときは:
   - **Omarchy のコマンド経由**にする (`omarchy pkg add` / `omarchy install ...` /
     `omarchy webapp ...`)。素の `pacman -S` や `pkexec pacman` は使わない。
   - **権限が必要な操作**は Omarchy コマンド経由で行う。AUR のように非対話で無理なものは
     `omarchy-launch-floating-terminal-with-presentation` でユーザーの端末に出して
     パスワードを入力してもらう(エージェントの bash には TTY が無く sudo が使えない)。
   - 入れる**前に既存手段を確認**する: Omarchy の Web アプリ版 / mise 管理の CLI /
     すでに入っているか (例: Discord は Web アプリ版が最初からあり、`gh` は mise に入っていた)。
4. **検証コマンドを必ず実行**して、**期待される出力**をドキュメントに残す。
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
- **特権**: エージェントの bash には **TTY が無い**ので `sudo` はプロンプトを出せない
  (実測: `sudo -v` → `sudo: a terminal is required to read the password`)。
  よってスキルの「端末が無い場合」に該当する。ただし:
  - **手順は必ず Omarchy コマンド経由**(`omarchy pkg add` / `omarchy install ...`)。
    素の `pacman -S` / `pkexec pacman -S` を自前で叩かない。
  - **AUR は root では入れられない**(makepkg / yay が root を拒否)。
    その場合は `omarchy-launch-floating-terminal-with-presentation '<omarchy-install-...>'`
    を使う。ユーザーの見えるフローティング端末で sudo を入力してもらえる
    (Omarchy メニューと同じ経路)。
  - 非対話で完結できるもの(システム設定の書き換え等)だけ `pkexec` を使う。
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

## 取り扱っている項目

適用手順は [setup/new-host.md](setup/new-host.md) を上から順に。詳細は各 `apps/*.md`。

| 領域 | 何をするか | 詳細 |
|------|-----------|------|
| 日本語入力 | fcitx5 + Mozc を入れ、`Ctrl+Space` で切替 | [apps/fcitx5-mozc.md](apps/fcitx5-mozc.md) |
| 候補ウィンドウ | 自作 `omarchy-tokyo-night` テーマ(Mellow 設計 + Tokyo Night 配色)を配置 | 同上 |
| 音声入力 | Voxtype を `small` + `ja` + VAD 有効 + GPU(Vulkan) にする | [apps/voxtype.md](apps/voxtype.md) |
| herdr | 純正キーに戻し、`prefix+,` `.` で workspace、`prefix+shift+,` `.` で agent を移動 | [apps/herdr.md](apps/herdr.md) |
| 入力デバイス | `kb_layout = us` / `natural_scroll = true` | [apps/hyprland-input.md](apps/hyprland-input.md) |
| 表示倍率 | 1.8x(2880x1800 で選べるのは 1.667 / 1.8 / 1.875) | [apps/display-scale.md](apps/display-scale.md) |
| Display パネル | bar widget を clone し、SCALE を11段スライダーにする | 同上 |
| Bitwarden | `bitwarden` + `bitwarden-cli` を入れ、`SUPER+SHIFT+/` を Bitwarden に向ける | [apps/bitwarden.md](apps/bitwarden.md) |
| Discord | 公式クライアント (`extra`) を入れ、初回起動で本体をDLする (Web アプリ版と重複しないよう注意) | [apps/discord.md](apps/discord.md) |
| CLI ツール | `gh` / `node` / `pi` / `codex` / `turso` は mise でグローバル管理 | [setup/new-host.md](setup/new-host.md) の 8 |
| GitHub SSH | 公式ホスト鍵を `known_hosts` に登録し、検証を無効化せず接続する | [apps/github-ssh.md](apps/github-ssh.md) |
| ブラウザ | Chrome(既定。AUR の google-chrome。ベースの chromium は残す) | [apps/browser.md](apps/browser.md) |
| エディタ | Zed を入れ、CLI 名 `zeditor` に `zed` symlink を張る | [apps/zed.md](apps/zed.md) |
| Nix | `omarchy pkg add nix` で入れ、nix-config の `torohash_omarchy` でエージェント設定だけを共有する (Omarchy 優先) | [apps/nix.md](apps/nix.md) |
| 既定エージェント | 未設定(Omarchy は既定を勝手に選ばない) | [apps/omarchy-agent.md](apps/omarchy-agent.md) |

## 別ホストへの適用

→ **[setup/new-host.md](setup/new-host.md)** を上から順に実行する。
`assets/omarchy-tokyo-night/` のコピーも含まれている。

---

## 注意点

| 項目 | 内容 |
|------|------|
| fcitx5 の起動時 IM | 終了時に `DefaultIM` を `mozc` に書き戻す癖があるため、**ログイン直後が日本語始まりになる可能性**。英数固定にするならログイン時に `fcitx5-remote -c` を実行する設定を足す |
| herdr `prefix+,` / `prefix+.` | IME オン中は `,`/`.` が `、`/`。` に化けて効かない可能性がある |
| Caps Lock の IME 切替 | 検討したが **`Ctrl+Space` 運用で決着**。`keyd` は導入しない |
| Display パネル clone | `omarchy update` 後にパネルが元に戻っていたら `setup/new-host.md` の 5 を再実行。QML は hot-reload されないので `omarchy restart shell` が必須 |
| Bitwarden の見た目 | `no_screen_share` のため**スクショで検証できない**。倍率が合わないと感じたら `--force-device-scale-factor` で調整 (`apps/bitwarden.md`) |
| classicui テーマ | 微調整は `~/.local/share/fcitx5/themes/omarchy-tokyo-night/theme.conf`。変更したら `assets/` にも同期 |

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
