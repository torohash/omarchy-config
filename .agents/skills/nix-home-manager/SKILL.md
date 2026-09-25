---
name: nix-home-manager
description: Nix (Arch 公式パッケージ) を入れ、torohash/nix-config の Home Manager 構成 torohash_omarchy を適用する (Pi のモデル設定・検索設定・自動圧縮)。Nix や Home Manager を導入・適用・確認するときに使う。
metadata:
  privilege: sudo
  depends: none
---

# Nix + Home Manager

Nix は `omarchy pkg add nix` で入れる (mise では入れられない。`/nix/store` と root の daemon が要る)。
nix-config の `torohash_omarchy` は Omarchy を優先する構成で、Pi の設定ファイルだけを扱う
(`.bashrc`・git・nvim・端末・fcitx5・herdr には触れない)。理由とハマりどころは [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
command -v nix >/dev/null && systemctl is-active --quiet nix-daemon.socket \
  && nix config show experimental-features | grep -q flakes \
  && readlink ~/.pi/agent/models.json | grep -q '^/nix/store/' \
  && echo "nix-home-manager: ok"
```

## 特権で行う操作

`command -v nix` が失敗する、または `nix-daemon.socket` が active でないときだけ。

```bash
omarchy pkg add nix
sudo systemctl enable --now nix-daemon.socket
```

## 実行

1. flakes を有効にする (重複して書かない)。

   ```bash
   mkdir -p ~/.config/nix
   grep -qs '^experimental-features' ~/.config/nix/nix.conf \
     || echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

2. nix-config を取得して registry に登録する (公開リポジトリなので認証は不要)。

   ```bash
   [ -d ~/dev/nix-config ] || git clone https://github.com/torohash/nix-config ~/dev/nix-config
   nix registry add nixcfg path:$HOME/dev/nix-config
   ```

3. Home Manager を適用する。`home-manager` コマンドが無い初回は `nix run` で実行する。

   ```bash
   if command -v home-manager >/dev/null; then
     home-manager switch --flake nixcfg#torohash_omarchy
   else
     nix run github:nix-community/home-manager -- switch --flake nixcfg#torohash_omarchy
   fi
   ```

## 検証

```bash
nix --version                                   # => nix (Nix) 2.x.x
nix store info                                  # => Store URL: daemon
readlink ~/.pi/agent/models.json                # => /nix/store/…-home-manager-files/.pi/agent/models.json
readlink ~/.pi/web-search.json                  # => /nix/store/…-home-manager-files/.pi/web-search.json
jq -c .compaction ~/.pi/agent/settings.json     # => {"enabled":true,"reserveTokens":150000}
readlink ~/.bashrc                              # => 何も出ない (Home Manager は .bashrc を持たない)
```

`home-manager` コマンドは次のログインから PATH に入る (`/etc/profile.d/nix-daemon.sh`)。

## 元に戻す

```bash
home-manager uninstall
sudo systemctl disable --now nix-daemon.socket
omarchy pkg drop nix
sudo rm -rf /nix ~/.config/nix ~/.local/state/nix ~/.nix-profile
```
