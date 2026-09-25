# Turso CLI — 理由・ハマりどころ

手順は [SKILL.md](SKILL.md)。

[Turso](https://turso.tech/) (SQLite 互換の libSQL を使うクラウド DB) の CLI。
DB の作成・トークン発行・`turso db shell` での SQL 実行・ローカル開発サーバ (`turso dev`) に使う。

## 入れ方の比較

| 候補 | 採否 | 理由 |
|------|------|------|
| mise (`aqua:tursodatabase/turso-cli`) | **採用** | Omarchy が CLI を入れるのと同じ経路。sudo 不要で公式のリリースバイナリを使う |
| AUR `turso-cli` / `turso-cli-bin` | 不採用 | pacman の公式リポジトリに無い。AUR はエージェントから非対話で入れられない |
| Nix | 不採用 | バイナリは Omarchy 側 (pacman / mise) で入れる方針 |

## ハマりどころ

- **名前**: AUR の `turso` / `turso-bin` / `turso-git` は別物 (組み込み DB エンジン)。CLI は `turso-cli`。
- **shim 経由で起動する**: PATH に `~/.local/share/mise/shims` が必要 (Omarchy の bash には最初から入っている)。
- **更新**: `mise up turso`。`omarchy update` では更新されない。
- 認証情報は `~/.config/turso/`。ホストごとに `turso auth login` をやり直す。

## 参考

- [tursodatabase/turso-cli](https://github.com/tursodatabase/turso-cli)
- [Turso CLI ドキュメント](https://docs.turso.tech/cli/introduction)
