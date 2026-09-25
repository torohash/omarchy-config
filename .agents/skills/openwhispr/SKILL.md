---
name: openwhispr
description: OpenWhispr (会議の議事録を取るアプリ。話者の区別つき。音声入力もできる) を AUR から入れ、Super+Shift+V で開けるようにする。録音などのキーはアプリの初期設定でユーザーが行う。議事録を取りたい、OpenWhispr を導入・確認するときに使う。
metadata:
  privilege: sudo
  depends: none
---

# OpenWhispr (議事録・音声入力)

会議の議事録 (Zoom / Teams の自動検出、話者の区別、メモ) と音声入力に使う。Omarchy の Voxtype は議事録を取れないので、Voxtype は入れず OpenWhispr に一本化する。
この skill の範囲は**インストールと、アプリを開くキー (`Super+Shift+V`) まで**。録音のキー・モデル・マイクは、アプリの初期設定でユーザーが決める。
理由・Voxtype との比較・キー選びの注意は [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
pacman -Q openwhispr-bin >/dev/null \
  && grep -q 'omarchy-config: openwhispr' ~/.config/hypr/bindings.lua \
  && echo "openwhispr: ok"
```

## 特権で行う操作

```bash
omarchy pkg aur add openwhispr-bin
```

## 実行

アプリを開くキー `Super+Shift+V` が無ければ、退避してから `~/.config/hypr/bindings.lua` の末尾に追記する。
起動済みでも `openwhispr` を実行するとコントロールパネルが開く。

```bash
if ! grep -q 'omarchy-config: openwhispr' ~/.config/hypr/bindings.lua; then
  mkdir -p ~/.local/state/omarchy-config/backups
  cp ~/.config/hypr/bindings.lua ~/.local/state/omarchy-config/backups/hypr-bindings.lua.$(date +%s)
  cat ~/dev/config/.agents/skills/openwhispr/files/bindings-overrides.lua >> ~/.config/hypr/bindings.lua
fi
hyprctl reload            # => ok
hyprctl configerrors      # => 空
```

## ユーザーに頼む操作

OpenWhispr を起動して初期設定をしてもらう (モデルの選択・ダウンロード、マイクの許可、キー。サインインは任意)。
キーを決めるときの注意を伝える:

- **Hyprland (Omarchy) が使っているキーは、アプリの登録画面で押しても入らない** (Hyprland が先に受け取る)。
  空いているかは次で確かめられる (出力が空なら空き。SUPER=64 SHIFT=1 CTRL=4 ALT=8 の合計とキー名):
  ```bash
  hyprctl binds -j | jq -r '.[] | select(.modmask == 65 and (.key | ascii_upcase) == "J" and .submap == "") | .description'
  ```
- OpenWhispr は既定のキー (`Control+Super`) の登録に失敗すると `F8` → `F9` → `Control+Shift+Space` の順に試す。
  意図しないキーにならないよう、キーは明示的に登録する。

## 検証

```bash
pacman -Q openwhispr-bin        # => openwhispr-bin 1.x.x
hyprctl binds -j | jq -r '.[] | select(.description == "OpenWhispr") | "\(.modmask) \(.key)"'   # => 65 V
```

## 元に戻す

`~/.config/hypr/bindings.lua` から追記したブロックを消して `hyprctl reload`。

```bash
omarchy pkg drop openwhispr-bin
rm -rf ~/.config/open-whispr    # 設定・議事録 (transcriptions.db) も消える
```
