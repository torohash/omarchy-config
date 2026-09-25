# Nix + Home Manager — AI エージェント設定の共有

## 何をするか / なぜ入れるか

[torohash/nix-config](https://github.com/torohash/nix-config) の Home Manager 構成
`torohash_omarchy` を当て、AI エージェント(Claude Code / Codex / Pi / OpenCode)の
rules・agents・skills などを他の OS(Ubuntu / Fedora / WSL)と共有する。

**Omarchy を優先する**。Omarchy が管理するシェル・git・nvim・端末・fcitx5・CLI は
Home Manager で扱わず、バイナリも Nix では入れない。
持ち主の一覧は nix-config の `docs/omarchy.md` を参照。

## 導入手順

### 1. Nix を入れる

Arch 公式の `extra/nix` を Omarchy 経由で入れる。mise では入れられない(`/nix/store` と root の daemon が必要なため)。
公式インストーラー(curl | sh)は使わない。`/etc` を自分で書き換えるうえ、`omarchy update` で更新されないため。

```bash
omarchy pkg add nix
sudo systemctl enable --now nix-daemon.socket
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

エージェントから行う場合は、スクリプトにまとめて
`omarchy-launch-floating-terminal-with-presentation '<script>'` で実行し、
ユーザーの端末で sudo のパスワードを入れてもらう。

### 2. nix-config を取得して適用する

```bash
gh repo clone torohash/nix-config ~/dev/nix-config
nix registry add nixcfg path:$HOME/dev/nix-config
nix run github:nix-community/home-manager -- switch --flake nixcfg#torohash_omarchy
```

以降の手順(`.bashrc` への追記、`settings.json` のマージ)は nix-config の `docs/omarchy.md`。

## ハマりどころ

- **`nix-users` グループは無い**: Arch の `nix` パッケージが作るのは `nixbld` だけ。
  `sudo usermod -aG nix-users "$USER"` は `usermod: group 'nix-users' does not exist`(終了コード 6)で失敗する。
  `/etc/nix/nix.conf` の `allowed-users` は既定で `*` なので、グループに入る必要はない。
- **flakes は既定で無効**: `~/.config/nix/nix.conf` の設定を忘れると `nix flake` 系のコマンドが使えない。

## 検証

```bash
nix --version                              # => nix (Nix) 2.35.x
systemctl is-active nix-daemon.socket      # => active
nix store info                             # => Store URL: daemon
nix config show experimental-features      # => fetch-tree flakes nix-command
cd ~/dev/nix-config && nix flake check --no-build   # => all checks passed!
```

## 撤去

```bash
home-manager uninstall                     # Home Manager の管理ファイルを外す
sudo systemctl disable --now nix-daemon.socket
omarchy pkg drop nix
sudo rm -rf /nix ~/.config/nix ~/.local/state/nix ~/.nix-profile
```

## 参考

- [Nix - ArchWiki](https://wiki.archlinux.org/title/Nix)
- [torohash/nix-config](https://github.com/torohash/nix-config)(`docs/omarchy.md`)
