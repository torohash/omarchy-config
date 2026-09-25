---
name: display-scale
description: Omarchy の Display パネル (bar の omarchy.monitor) を複製して、SCALE の 6 個の固定ボタンを 11 段のスライダーに作り替え、表示倍率を設定する。表示倍率を細かく選びたい、Display パネルの改造を適用・確認するとき、omarchy update 後にパネルが戻ったときに使う。
metadata:
  privilege: user
  depends: none
---

# Display パネルのスライダー化と表示倍率

Omarchy の SCALE は `1 / 1.25 / 1.6 / 2 / 3 / 4` の 6 ボタンで、中間の値を選べない。
`omarchy plugin clone` で複製し、SCALE を 11 段のスライダーにした `Panel.qml` に差し替える
(解像度で選べない値はスライダーから自動で間引かれる)。理由・Hyprland の倍率の制約は [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
p=~/.config/omarchy/plugins/$(whoami).monitor
cmp -s "$p/Panel.qml" ~/dev/config/.agents/skills/display-scale/files/Panel.qml \
  && grep -q "\"$(whoami).monitor\"" ~/.config/omarchy/shell.json \
  && echo "display-scale: ok"
```

## 実行

1. 複製が無ければ作る (bar の widget も `<ユーザー名>.monitor` に差し替わる)。

   ```bash
   [ -d ~/.config/omarchy/plugins/$(whoami).monitor ] || omarchy plugin clone omarchy.monitor
   ```

2. 改造した `Panel.qml` で上書きし、shell を再起動する (QML の変更は再起動しないと効かない)。

   ```bash
   cp ~/dev/config/.agents/skills/display-scale/files/Panel.qml ~/.config/omarchy/plugins/$(whoami).monitor/Panel.qml
   omarchy plugin validate ~/.config/omarchy/plugins/$(whoami).monitor   # => exit 0
   omarchy restart shell
   ```

## ユーザーに頼む操作

表示倍率を決めてもらう (好みとディスプレイで変わる)。Display パネルのスライダーで選ぶか、値を聞いて設定する。

```bash
hyprctl monitors -j | jq -c '.[] | {name, width, height, scale}'   # 解像度と今の倍率
omarchy hyprland monitor scaling <値>                              # 例: 1.8。up / down は 1.6 → 2 に飛ぶので使わない
```

## 検証

```bash
omarchy plugin validate ~/.config/omarchy/plugins/$(whoami).monitor   # => exit 0
hyprctl monitors -j | jq '.[0].scale'                                 # => 決めた倍率
tr -c '[:print:]\n' '\n' < /run/user/$(id -u)/quickshell/by-id/*/log.qslog \
  | grep -iE "TypeError|ReferenceError|Binding loop"                  # => 何も出ない
```

見た目: Display パネルを開くと、SCALE の行がスライダーになり、ヘッダーの右に今の倍率 (`1.8x` など) が出る。

## 元に戻す

```bash
omarchy plugin remove $(whoami).monitor --yes   # 退避して omarchy.monitor に戻る
omarchy restart shell
```
