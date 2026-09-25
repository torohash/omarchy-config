# Turso CLI — libSQL / Turso Cloud の操作

## 何をするツールか

[Turso](https://turso.tech/)(SQLite 互換の libSQL を使うクラウド DB)の CLI。
DB の作成・トークン発行・`turso db shell` での SQL 実行・ローカル開発サーバ(`turso dev`)に使う。

## 入れるもの

`turso`(mise の registry 名。実体は `aqua:tursodatabase/turso-cli`)を **mise でグローバル**に入れる。

| 候補 | 採否 | 理由 |
|------|------|------|
| mise (`aqua:tursodatabase/turso-cli`) | **採用** | Omarchy が CLI を入れるのと同じ経路。sudo 不要で、公式のリリースバイナリを使う |
| AUR `turso-cli` / `turso-cli-bin` | 不採用 | pacman の公式リポジトリには無い。AUR にするとエージェントから非対話で入れられない |
| Nix (`nixpkgs#turso-cli`) | 不採用 | Omarchy 優先の方針により、バイナリは Nix で入れない |

**名前に注意**: AUR の `turso` / `turso-bin` / `turso-git` は **別物**(SQLite 互換の組み込み DB エンジン)。CLI は `turso-cli`。

## 導入手順

```bash
mise use -g turso        # ~/.config/mise/config.toml に turso = "latest" が追記される
turso auth login         # ブラウザで GitHub 認証する(ヘッドレスなら turso auth login --headless)
```

## 検証

```bash
turso --version                   # => turso version v1.0.x
command -v turso                  # => ~/.local/share/mise/shims/turso
mise ls --global | grep turso     # => turso  1.0.x  ~/.config/mise/config.toml  latest
turso auth whoami                 # => ログイン中のユーザー名(ログイン後)
```

## ハマりどころ

- **shim 経由で起動する**: PATH に `~/.local/share/mise/shims` が必要。Omarchy の bash には最初から入っている。
- **アップデート**: `mise up turso`。`omarchy update` からは更新されない。
- 認証情報は `~/.config/turso/` に保存される。ホストごとに `turso auth login` をやり直す。

## 撤去

```bash
mise unuse -g turso
rm -rf ~/.config/turso       # 認証情報も消す場合
```

## 参考

- [tursodatabase/turso-cli](https://github.com/tursodatabase/turso-cli)
- [Turso CLI ドキュメント](https://docs.turso.tech/cli/introduction)
