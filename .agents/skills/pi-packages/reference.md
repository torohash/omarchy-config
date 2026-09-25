# Pi の package — 用途・方針

手順は [SKILL.md](SKILL.md)。

| source | 用途 |
|--------|------|
| `npm:pi-web-access` | Web 検索・取得。設定は `~/.pi/web-search.json` (skill `nix-home-manager` が配置) |
| `npm:@ff-labs/pi-fff` | ファイル検索 |
| `npm:@ogulcancelik/pi-session-recall` | 過去セッションの参照 |
| `npm:pi-token-speed` | トークン速度の表示 |

## 方針

- **Home Manager で管理しない**: `~/.pi/agent/settings.json` の `packages` は Pi が書き換える。
  Home Manager が丸ごと書くと、`pi install` で足したものが switch のたびに消える。
- version は固定しない。実体は Pi が `~/.pi/agent/npm/` に入れる。更新は `pi update --extensions`。
- `pi install` は `-l` 無しだとグローバル (`~/.pi/agent/settings.json`)、`-l` ありだとプロジェクト (`.pi/settings.json`)。
- nix-config の `docs/pi-packages.md` にも同じ一覧がある (Omarchy 以外のホスト向け)。変えたら両方を合わせる。
