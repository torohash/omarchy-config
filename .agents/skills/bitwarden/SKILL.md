---
name: bitwarden
description: Bitwarden (デスクトップアプリ + CLI の bw) を入れ、Omarchy の Passwords キー (SUPER+SHIFT+/) を 1Password から Bitwarden に向ける。パスワードマネージャを導入・確認するとき、Passwords キーで 1Password のインストーラが開くときに使う。
metadata:
  privilege: sudo
  depends: none
---

# Bitwarden

1Password ではなく Bitwarden を使う。パッケージは両方 `extra` (AUR 不要)。
Omarchy 既定の Passwords キーは 1Password を指しているので差し替える。理由とハマりどころは [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
pacman -Q bitwarden bitwarden-cli >/dev/null \
  && grep -q 'launch = "bitwarden-desktop"' ~/.config/hypr/bindings.lua \
  && [ "$(omarchy menu keybindings --print | grep -c '→ Passwords')" = 1 ] \
  && echo "bitwarden: ok"
```

## 特権で行う操作

```bash
omarchy pkg add bitwarden bitwarden-cli
```

## 実行

1. Passwords キーの差し替えが無ければ、退避してから `~/.config/hypr/bindings.lua` の末尾に追記する。

   ```bash
   if ! grep -q 'launch = "bitwarden-desktop"' ~/.config/hypr/bindings.lua; then
     mkdir -p ~/.local/state/omarchy-config/backups
     cp ~/.config/hypr/bindings.lua ~/.local/state/omarchy-config/backups/hypr-bindings.lua.$(date +%s)
     cat ~/dev/config/.agents/skills/bitwarden/files/bindings-overrides.lua >> ~/.config/hypr/bindings.lua
   fi
   hyprctl reload            # => ok
   hyprctl configerrors      # => 空
   ```

## ユーザーに頼む操作

Bitwarden を起動してログインしてもらう (`SUPER+SHIFT+/`)。CLI を使うなら `bw login`。

## 検証

```bash
pacman -Q bitwarden bitwarden-cli                               # => 2 行
bw --version                                                    # => 2026.x.x
omarchy menu keybindings --print | grep '→ Passwords'           # => SUPER SHIFT + SLASH → Passwords (1 行だけ)
```

Bitwarden の窓はスクリーンショットでは真っ黒に写る (Omarchy の `no_screen_share`。正常)。

## 元に戻す

`~/.config/hypr/bindings.lua` から追記したブロックを消して `hyprctl reload`。

```bash
omarchy pkg drop bitwarden bitwarden-cli
rm -rf ~/.config/Bitwarden ~/.config/"Bitwarden CLI"   # 金庫のキャッシュも消える (同期していればサーバーに残る)
```
