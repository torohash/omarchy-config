---
name: pi-packages
description: Pi (コーディングエージェント) の package (拡張) を pi install で入れる。入れるものは files/packages.txt。Pi の拡張を導入・追加・削除するときに使う。
metadata:
  privilege: none
  depends: none
---

# Pi の package

Pi 本体は Omarchy が mise で入れている。package は Pi 自身の `pi install` で入れる
(Home Manager では管理しない)。入れるものは [files/packages.txt](files/packages.txt)。用途と方針は [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
installed=$(pi list 2>/dev/null)
missing=$(grep -v -e '^#' -e '^$' ~/dev/config/.agents/skills/pi-packages/files/packages.txt \
  | while read -r src; do grep -qxF "  $src" <<<"$installed" || echo "$src"; done)
[ -z "$missing" ] && echo "pi-packages: ok" || { echo "missing:"; echo "$missing"; false; }
```

## 実行

入っていないものだけ入れる (`-l` を付けないのでグローバルの `~/.pi/agent/settings.json` に入る)。

```bash
installed=$(pi list 2>/dev/null)
grep -v -e '^#' -e '^$' ~/dev/config/.agents/skills/pi-packages/files/packages.txt \
  | while read -r src; do grep -qxF "  $src" <<<"$installed" || pi install "$src"; done
```

## 検証

```bash
pi list
# => User packages:
#      npm:pi-web-access
#        /home/<user>/.pi/agent/npm/node_modules/pi-web-access
#      … (packages.txt の全部が出る)
```

## 追加・削除するとき

- 全ホストで使う: `pi install <source>` してから `files/packages.txt` に 1 行足す。
- そのプロジェクトだけで使う: `pi install -l <source>` (プロジェクトの `.pi/settings.json` に入る)。packages.txt には書かない。
- ローカルのリポジトリ: `pi install ~/dev/<repo>`。clone していないホストでは存在しないので、packages.txt には書かない。
- 削除: `pi remove <source>` して packages.txt からも消す。

## 元に戻す

```bash
grep -v -e '^#' -e '^$' ~/dev/config/.agents/skills/pi-packages/files/packages.txt | xargs -r -n1 pi remove
```
