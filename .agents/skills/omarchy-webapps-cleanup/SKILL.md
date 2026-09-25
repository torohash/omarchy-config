---
name: omarchy-webapps-cleanup
description: Omarchy が最初から入れている 37signals の Web アプリのうち使わないもの (HEY のメール・カレンダー、Basecamp) を片付ける。ランチャーを消し、HEY を開くキー (Super+Shift+E / C / Alt+E) と mailto の関連付けを外す。HEY や Basecamp を使わない、メールのリンクで HEY が開くのをやめたいときに使う。
metadata:
  privilege: none
  depends: none
---

# 使わない Omarchy の Web アプリを片付ける

HEY (37signals の有料メール・カレンダー) と Basecamp (37signals のプロジェクト管理) は、Omarchy の初期の Web アプリ。
使わないので、ランチャーとキーと `mailto` の関連付けを外す。空いたキーはほかのアプリに使える。理由は [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
[ ! -e ~/.local/share/applications/HEY.desktop ] && [ ! -e ~/.local/share/applications/Basecamp.desktop ] \
  && ! grep -qs 'mailto=HEY.desktop' ~/.config/mimeapps.list \
  && grep -q 'omarchy-config: omarchy-webapps-cleanup' ~/.config/hypr/bindings.lua \
  && echo "omarchy-webapps-cleanup: ok"
```

## 実行

1. ランチャーを消す。`omarchy webapp remove` は `mimeapps.list` の関連付けを残すので、`mailto` の行も消す。

   ```bash
   for app in HEY Basecamp; do
     [ -e ~/.local/share/applications/$app.desktop ] && OMARCHY_REMOVE_NOTIFY=false omarchy webapp remove "$app"
   done
   B=~/.local/state/omarchy-config/backups; mkdir -p "$B"
   if grep -qs 'mailto=HEY.desktop' ~/.config/mimeapps.list; then
     cp ~/.config/mimeapps.list "$B/mimeapps.list.$(date +%s)"
     sed -i '/^x-scheme-handler\/mailto=HEY.desktop$/d' ~/.config/mimeapps.list
   fi
   ```

2. HEY を開くキーを外す (Omarchy の既定は `hl.unbind` で打ち消す)。

   ```bash
   if ! grep -q 'omarchy-config: omarchy-webapps-cleanup' ~/.config/hypr/bindings.lua; then
     cp ~/.config/hypr/bindings.lua "$B/hypr-bindings.lua.$(date +%s)"
     cat ~/dev/config/.agents/skills/omarchy-webapps-cleanup/files/bindings-overrides.lua >> ~/.config/hypr/bindings.lua
   fi
   hyprctl reload            # => ok
   hyprctl configerrors      # => 空
   ```

## 検証

```bash
ls ~/.local/share/applications/{HEY,Basecamp}.desktop 2>&1 | grep -c 'No such file'   # => 2
xdg-mime query default x-scheme-handler/mailto                                        # => HEY.desktop 以外 (空でもよい)
hyprctl binds -j | jq -r '.[] | select(.description | test("^(Email|Calendar|New email)$")) | .description'
# => Calendar だけ (SUPER+CTRL+ALT+D のバーのカレンダー。HEY ではない)
```

## 元に戻す

`~/.config/hypr/bindings.lua` から追記したブロックを消して `hyprctl reload`。ランチャーと mailto の関連付けを戻すなら:

```bash
omarchy install preinstalls        # Omarchy の初期の Web アプリなどを入れ直す (HEY / Basecamp を含む)
```
