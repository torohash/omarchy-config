# fcitx5 + Mozc — 日本語入力

Omarchy は **fcitx5 を標準で導入済み**。Mozc だけ足せば日本語入力できる。

- 導入済み (Omarchy 標準): `fcitx5` `fcitx5-gtk` `fcitx5-qt`
- 追加導入: `fcitx5-mozc` (IM 本体)。候補ウィンドウの見た目は自作テーマで対応 (下記)
- fcitx5 は systemd の **ユーザーサービス `omarchy-fcitx5.service`** が管理

## 環境変数 (Omarchy が既定で設定済み)

```
XMODIFIERS=@im=fcitx
QT_IM_MODULE=fcitx
SDL_IM_MODULE=fcitx
```

`GTK_IM_MODULE` は設定されていないが、Wayland の text-input プロトコルを使うため
GTK アプリでも動作する(`fcitx5-diagnose` は警告を出すが問題なし)。
XWayland アプリ等で日本語が入らない場合のみ `GTK_IM_MODULE=fcitx` の追加を検討。

## インストール

```bash
# ふつう (ターミナルでパスワード入力可)
omarchy pkg add fcitx5-mozc            # Omarchy 流 (中で sudo pacman -S)
# or
sudo pacman -S fcitx5-mozc

# agent など非対話 (ターミナルが無い) 場合の特権実行
pkexec pacman -S --noconfirm --needed fcitx5-mozc
```

> Omarchy スキルの指針: ターミナルがあれば `sudo`、無ければ `pkexec`。
> `omarchy pkg add` は自身で sudo するため `pkexec` で二重に包まない
> (agent からは `pkexec pacman` を直接叩くのが素直)。

候補ウィンドウの見た目は、パッケージのテーマではなく**自作テーマ**を使っている
(後述の「候補ウィンドウ (classicui) のテーマ」)。追加パッケージは不要。

(参考) 既製テーマを使いたい場合:

```bash
pkexec pacman -S --noconfirm --needed fcitx5-material-color   # Material 配色
```

## プロファイル (登録する入力メソッド)

`~/.config/fcitx5/profile`:

```ini
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=keyboard-us

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=mozc
Layout=

[GroupOrder]
0=Default
```

- Mozc の IM 名は `mozc`、アドオン名は `fcitx_mozc`、表示名は `Mozc`。
- `DefaultIM` は起動時に使う IM (本環境は `keyboard-us` = 英数始まりを狙う)。

### 反映

```bash
omarchy restart xcompose     # ← fcitx5 を「Omarchy の作法」で再起動
```

`omarchy restart xcompose` の中身: ユーザーサービス停止 → `pkill -x fcitx5` → サービス開始。

## 操作キー

- **`Ctrl+Space`** … IME ON/OFF (日本語⇔英数)。fcitx5 既定の `TriggerKeys` に含まれる。
- 既定 `TriggerKeys`: `Control+space`, `Zenkaku_Hankaku`, `Hangul`
  (`Shift_L` は `AltTriggerKeys`)

## 候補ウィンドウ (classicui) のテーマ

fcitx5 の候補ウィンドウは `classicui` UI が描画する。素のままだと装飾の無い枠になる。
**GNOME のようにデスクトップシェルが描いてくれる仕組みは Hyprland には無い**ので、
fcitx5 のテーマで見た目を決める。

### 現在: 自作 Tokyo Night テーマ (`omarchy-tokyo-night`)

Omarchy のテーマ (Tokyo Night, accent `#7aa2f7`) に合わせた自作テーマ。
**設計は [sanweiya/fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes) を参考**にした
(実際のスクリーンショットを確認し、一番洗練されていると判断)。

配置先: `~/.local/share/fcitx5/themes/omarchy-tokyo-night/`
一式はこのリポジトリの [`../assets/omarchy-tokyo-night/`](../assets/omarchy-tokyo-night/) に保存
(他ホストへはコピーするだけ)。

| ファイル | 内容 |
|---------|------|
| `theme.conf` | 色・余白・画像の定義 |
| `panel.svg` | **31x31 の角丸長方形 (radius 9.5)** + 控えめな枠。パネル/メニュー背景 |
| `highlight.svg` | **31x31 の角丸ピル (radius 15.5)**。選択候補の背景 |
| `prev.svg` / `next.svg` | ページ送りボタン |
| `radio.svg` / `arrow.svg` | メニューのチェック / サブメニュー印 |

**SVG を 9 スライス**で伸ばすのがコツ:
- `[InputPanel/Background] Image=panel.svg` + `Margin` 15 (角丸半径より大きい値)
- `[InputPanel/Highlight] Image=highlight.svg` + `Margin` L/R=15, T/B=10
- SVG なら高 DPI でもジャギらない (PNG だと粗くなる)

`~/.config/fcitx5/conf/classicui.conf`:

```ini
Theme=omarchy-tokyo-night
UseAccentColor=False   # ポータルのアクセント色で上書きさせない (決定的にする)
PerScreenDPI=True
Font=Sans 12           # フォントはテーマではなくここ
MenuFont=Sans 12
```

適用は **fcitx5 のプロセス再起動**が必要 (下記ハマりどころ参照)。

```bash
pkill -9 -x fcitx5      # 終了時の保存で上書きされないよう SIGKILL
# systemd の Restart=always で数秒後に自動復帰
```

### 参考: 既製テーマ (実物のスクショを確認済み)

| テーマ | URL | 評価 |
|--------|-----|------|
| **Mellow** | https://github.com/sanweiya/fcitx5-mellow-themes | ★217。**丸角 + 上品な枠 + 角丸ハイライトで一番きれい**。AUR: `fcitx5-mellow-themes-git`。本テーマの設計元 |
| Tokyo Night | https://github.com/ch3n9w/fcitx5-Tokyonight | 配色は Tokyo Night (Storm/Day)。ただし平坦で角丸なし |
| Round Simple | https://github.com/StarWhiteIsBusy/Round-Simple-Fcitx5-Skin | 丸角 + Noctalia Material You 連動 |
| Ori | https://github.com/Reverier-Xu/Ori-fcitx5 | 丸角のシンプル系 |
| Fluent | https://github.com/Reverier-Xu/Fluent-fcitx5 | Fluent Design。影/ぼかしは Wayland では効かない (作者明記) |
| Catppuccin | https://github.com/catppuccin/fcitx5 | `enable-rounded.sh` で丸角化 |
| Persona 5 | https://github.com/Liushenwuzhu-Alpaca/fcitx5-p5-phantom-theme | 攻めたデザイン |

一覧: https://github.com/topics/fcitx5-theme / https://aur.archlinux.org/packages?K=fcitx5-theme

### Wayland での制約 (重要)

- **ぼかしは KWin 専用** (`EnableBlur`)。Hyprland では無効。
- **影 (`ShadowMargin`) も Wayland では効かない** — パネル位置を fcitx5 ではなく Wayland 側が
  決めるため (Fluent 作者の README に明記)。
- 丸角は**背景画像 (SVG) + 9 スライス**で作るのが唯一の方法。専用オプションは無い。

### theme.conf の書式 (fcitx5 classicui)

`~/.local/share/fcitx5/themes/<name>/theme.conf` に INI 形式で書く。
`classicui.conf` の `Theme=` で選択。主なキー:

| セクション | キー |
|-----------|------|
| `[Metadata]` | `Name` `Version` `Author` `Description` `ScaleWithDPI` |
| `[InputPanel]` | `NormalColor`(通常候補) `HighlightCandidateColor`(選択候補の文字) `HighlightColor`/`HighlightBackgroundColor`(preedit) `CandidateLabelColor` `HighlightCandidateLabelColor` `CandidateCommentColor` `Spacing` `PageButtonAlignment` `FullWidthHighlight` `LabelTextSizeFactor` `CommentTextSizeFactor` |
| `[InputPanel/TextMargin]` `[InputPanel/ContentMargin]` `[InputPanel/ShadowMargin]` | `Left` `Right` `Top` `Bottom` |
| `[InputPanel/Background]` | `Image` `Color` `BorderColor` `BorderWidth` `Overlay` `Gravity` `OverlayOffsetX/Y` `HideOverlayIfOversize` + `[InputPanel/Background/Margin]` `[InputPanel/Background/OverlayClipMargin]` |
| `[InputPanel/Highlight]` | 背景と同じキー + `HighlightClickMargin` |
| `[InputPanel/PrevPage]` `[InputPanel/NextPage]` | `Image` + `ClickMargin` |
| `[Menu]` | `NormalColor` `HighlightCandidateColor` `Spacing` |
| `[Menu/Background]` `[Menu/Highlight]` `[Menu/Separator]` `[Menu/CheckBox]` `[Menu/SubMenu]` | 背景と同じキー |
| `[Menu/TextMargin]` `[Menu/ContentMargin]` | 余白 |
| `[AccentColorField]` | `UseAccentColor=True` のときアクセント色を適用するフィールド番号 |

**注意点:**
- **`Font` はテーマ項目ではない**。`classicui.conf` 側の `Font` / `MenuFont` で指定する。
  (`fcitx5-material-color` の theme.conf にある `Font=` は無効)
- `[InputPanel/Background]` で `Image` を指定すると `Color`/`BorderColor`/`BorderWidth` は
  **無視される** (画像が全部描く)。
- **角丸の専用オプションは無い**。背景画像 (角丸 PNG) + 9 スライス `Margin` で表現する。
  `Margin` は角丸半径 + 枠線ぶん以上にする。
- `EnableBlur` は **KWin 専用**。Hyprland ではぼかしは効かない。
- テーマの画像は `ScaleWithDPI` で DPI スケールされる。`<name>@2x.<ext>` を置くと
  スケール別画像も使われる。

### 見つけたテーマ候補 (未導入)

| 入手先 | 名前 | 特徴 |
|--------|------|------|
| repo | `fcitx5-breeze` | KDE Breeze 風 |
| repo | `fcitx5-nord` | Nord 配色 |
| repo | `fcitx5-material-color` | Material 配色 (導入済みだが現在は未使用) |
| AUR | `fcitx5-skin-fluentdark-git` | Fluent Design 風の**影 + ぼかし**付き (!+5) |
| AUR | `fcitx5-theme-dracula-git`, catppuccin 系 ほか | 各種配色 |

> AUR の Fluent 系は影・ぼかし付きで見た目が近いが、ぼかしは KWin 専用。
> 導入はユーザー判断で。

### classicui の全設定キー (既定値)

`Vertical Candidate List=False` / `WheelForPaging=True` / `Font=Sans 10` /
`MenuFont=Sans 10` / `TrayFont=Sans Bold 10` / `PreferTextIcon=False` /
`ShowLayoutNameInIcon=True` / `UseInputMethodLanguageToDisplayText=True` /
`Theme=default` / `DarkTheme=default-dark` / `UseDarkTheme=False` /
`UseAccentColor=True` / `PerScreenDPI=False` / `ForceWaylandDPI=0` / `EnableFractionalScale=True`

## 診断・操作用コマンド

```bash
fcitx5-diagnose                  # 総合診断 (環境変数, アドオン, IC 等)
fcitx5-remote                    # 状態: 0=off 1=inactive(英数) 2=active(日本語)
fcitx5-remote -n                 # 現在の IM 名
fcitx5-remote -t                 # active/inactive トグル (Ctrl+Space 相当)
fcitx5-remote -s mozc            # IM を mozc に切替
fcitx5-remote -r                 # 設定リロード (※後述の落とし穴あり)
fcitx5-configtool                # GUI 設定 (IM 追加/既定変更など)
```

DBus で直接調べる:

```bash
# 利用可能な IM 一覧
gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller \
  --method org.fcitx.Fcitx.Controller1.AvailableInputMethods
# グループ情報 (name, defaultIM, layout, items...)
gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller \
  --method org.fcitx.Fcitx.Controller1.FullInputMethodGroupInfo "Default"
# classicui 設定
gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller \
  --method org.fcitx.Fcitx.Controller1.GetConfig "fcitx://config/addon/classicui"
```

`SetInputMethodGroupInfo(group, defaultLayout, items)` でグループを編集できる
(第2引数は **レイアウト**であり `DefaultIM` ではない)。

## ハマりどころ / 知見

- **fcitx5 は終了時に設定ファイルを書き戻す**。事前に `~/.config/fcitx5/profile` を
  手で書いても、起動中インスタンスが終了する際に上書きされることがある。
  - `DefaultIM` は fcitx5 が `mozc` に書き戻す傾向 (Mozc が最初の「実 IM」のため)。
  - 手書き設定を確実に読ませたいときは **`pkill -9 -x fcitx5`** で保存させずに再起動
    (systemd の `Restart=always` で数秒後に自動復帰)。
- **`fcitx5-remote -r` は profile / classicui を読まない**ことがある。テーマや IM 構成を
  変えたら **プロセス再起動** (`omarchy restart xcompose` か SIGKILL) が必要。
- **既定 `ActiveByDefault=False`** でも、`DefaultIM=mozc` の場合は起動時に日本語
  (state=2) になることがある。英数始まりにしたい時は `fcitx5-remote -c` で inactivate
  するか、`fcitx5-configtool` で既定 IM を調整。
- **Caps Lock は fcitx5 のホットキーに直接できない**。切替キーとして使えるのは
  `Control+space` / `Zenkaku_Hankaku` 等のみ。Caps で切り替えたい場合は **keyd** で
  `capslock = zenkaku_hankaku` 等に remap する (→ 後述)。
- **Caps Lock は Omarchy 既定で Compose キー** (`kb_options="compose:caps,..."`)。
  `~/.XCompose` により Caps→Space→n で名前などが打てる。Caps を IME に使うと Compose は失う。

### (参考) keyd で Caps Lock を IME 切替にする場合

```bash
pkexec pacman -S --noconfirm --needed keyd
# /etc/keyd/default.conf
#   [ids]
#   *
#   [main]
#   capslock = zenkaku_hankaku   # or henkan
sudo systemctl enable --now keyd
```

## 撤去

```bash
omarchy pkg drop fcitx5-mozc fcitx5-material-color
rm -f ~/.config/fcitx5/profile ~/.config/fcitx5/conf/classicui.conf
omarchy restart xcompose
```
