# fcitx5 + Mozc — 日本語入力

Omarchy は **fcitx5 を標準で導入済み**。Mozc だけ足せば日本語入力できる。

- 導入済み (Omarchy 標準): `fcitx5` `fcitx5-gtk` `fcitx5-qt`
- 追加導入: `fcitx5-mozc` (IM 本体), `fcitx5-material-color` (候補ウィンドウのテーマ)
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

候補ウィンドウのテーマ (任意だが推奨):

```bash
pkexec pacman -S --noconfirm --needed fcitx5-material-color
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

fcitx5 の候補ウィンドウは `classicui` UI が描画する。素のままだと**プレーンな灰色枠**で
ダサい。`fcitx5-material-color` を入れてテーマを指定する。

`~/.config/fcitx5/conf/classicui.conf`:

```ini
# Theme: any Material-Color-* / default / default-dark
Theme=Material-Color-Blue
PerScreenDPI=True
```

利用可能テーマ: `Material-Color-{Black,Blue,Brown,DeepPurple,Indigo,Orange,Pink,Red,SakuraPink,Teal}`,
`default`, `default-dark`。Tokyo Night (青アクセント) には `Material-Color-Blue` が合う。

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
