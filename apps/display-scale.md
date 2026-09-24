# Display scale — 表示倍率と Display パネルのスライダー化

bar の Display パネル (bar widget `omarchy.monitor`) の表示倍率まわりの話。
**2x はでかすぎ / 1.6x はやや小さい**ので中間を模索したく、固定6プリセットの
SCALE 行を**スライダー(11段)に作り替えた**。

## 大前提: Hyprland が受け付ける倍率は飛び飛び

Hyprland の `monitor scale` は「モードが整数の論理ピクセルに割り切れる」値しか取れない。
実装は `gcd(width*120, height*120)` の約数 (`/usr/share/omarchy/bin/omarchy-hyprland-monitor-scaling`
の `clean_scale()`)。本機 **eDP-1 = 2880x1800 → gcd = 43200** なので:

```
1  1.125  1.2  1.25  1.333  1.5  1.6  1.667  1.8  1.875
2  2.25   2.4  2.5   2.667  3    3.333 3.6   3.75  4
```

**1.6〜2.0 の中間は 1.667 / 1.8 / 1.875 の3つだけ。** 1.7 や 1.75 を指定しても
近い有効値 (1.8) に切り上げられる。ボタンやスライダーを増やしても
**この制約は変わらない**ので、「段階を増やす」の実体は「有効値を全部見せる」こと。

- 論理サイズ: 1.6→1800x1125 / 1.667→1728x1080 / 1.8→1600x1000 / 1.875→1536x960 / 2→1440x900

## 何を変えたか

`/usr/share/omarchy/shell/plugins/panels/monitor/Panel.qml` は SCALE を
`scalePresets = ["1","1.25","1.6","2","3","4"]` の**6個のボタン**で描いていた。
→ `omarchy plugin clone` で複製し、TEXT SIZE と同じ `PanelSlider` に置換:

| 元 | 変更後 |
|----|--------|
| `Grid` + `Repeater` + `ScalePill` (6ボタン) | `CursorSurface` + `PanelSlider` (11ノッチ) |
| 6プリセット固定 | `["1","1.25","1.5","1.6","1.667","1.8","1.875","2","2.5","3","4"]` |
| ヘッダー右 = モニタ名のみ | 現在値 (`1.8x`) + 複数ディスプレイ時はモニタ名 |
| j/k でボタン移動, h/l でプリセット移動 | h/l で1段ずつ (`adjustScale`) |

`Model.availableScales()` が**解像度に合わない値を自動で捨てる**ので、
候補を多めに書いても他解像度・他ホストでは勝手に間引かれる
(ノッチ数 = そのディスプレイで実際に選べる段数)。

操作: ドラッグ/クリック = その段へ / `h` `l` = 1段ずつ / ホイール可。
クリック確定時にだけ `omarchy-hyprland-monitor-scaling <値>` を叩く
(ドラッグ中は叩かない)。

## 導入手順 (コマンドそのまま)

```bash
# 1. 雛形を複製 (bar widget の差し替えまで自動でやってくれる)
omarchy plugin clone omarchy.monitor

# 2. 改造版 Panel.qml を上書き (このファイルだけ差し替えればよい)
cp ~/dev/config/assets/torohash.monitor/Panel.qml \
   ~/.config/omarchy/plugins/$(whoami).monitor/Panel.qml

# 3. 反映 (QML の変更は hot-reload では効かない → shell 再起動)
omarchy restart shell
```

`assets/torohash.monitor/` には `Panel.qml` の他に `Model.js` / `manifest.json` も
置いてある(複製直後と同一内容。丸ごと `cp -r` してもよい)。

## 検証 (実際に実行した結果)

```bash
# 段の一覧とライブ値 → 段番号の対応 (Model.js を node で直接実行)
node -e '...'          # available: ["1","1.25","1.5","1.6","1.667","1.8","1.875","2","2.5","3","4"] count=11
                       # live 1.6 -> index 3 / 1.8 -> index 5 / 1.875 -> index 6

# 倍率の適用
omarchy-hyprland-monitor-scaling 1.8
hyprctl monitors -j | jq '.[0].scale'                    # => 1.8
omarchy-shell omarchy.monitor state | jq -r .scale       # => 1.8

# パネルの見た目 (grim + magick で切り出して確認)
omarchy-shell omarchy.monitor open && grim /tmp/panel.png
magick /tmp/panel.png -crop 720x1250+2160+0 +repage /tmp/crop.png
# → SCALE 行が 11ノッチのスライダー、ヘッダー右が "1.6x" → "1.8x" に追従

# プラグインの健全性 / QML エラー
omarchy plugin validate ~/.config/omarchy/plugins/torohash.monitor   # => exit 0
tr -c '[:print:]\n' '\n' < /run/user/1000/quickshell/by-id/*/log.qslog \
  | grep -iE "TypeError|ReferenceError|Binding loop"                 # => 何も出ない
```

## ハマりどころ

1. **QML の変更は hot-reload では効かない。** journal には
   `DEBUG qml: Local plugin changed, reloading: torohash.monitor` と出るのに、
   開いたパネルは**旧 UI (6ボタン) のまま**だった。`omarchy restart shell` で直る。
   ローカルプラグインを触ったら再起動まで疑うこと。
2. `/usr/share/omarchy/` は**編集禁止**(`omarchy update` で消える)。
   `omarchy plugin clone` で `~/.config/omarchy/plugins/` に複製してから触る。
3. 段を増やしても**有効値は増えない**(先頭の割り切れ制約)。
4. **GDK_SCALE は整数丸め**。`~/.config/hypr/monitors.lua` の `omarchy_gdk_scale` は
   `round(scale)` なので 1.6 でも 1.8 でも `GDK_SCALE=2` のまま。結果 **GTK アプリだけ
   実質 2/1.8 = 1.11倍**でかく見える(1.6 のときは 2/1.6 = 1.25倍)。
   つまり倍率を上げると GTK の相対的なズレは**緩和される**方向。
   (環境変数は Hyprland 起動時に効くので、変わる値のときは再ログインが要る)
5. 文字だけを細かく詰めたいなら別系統のレバーがある:
   `omarchy display text size 13` (shell base-size / GTK factor / terminal pt を同時に変更。
   9〜20px の整数全部を受ける。パネルの TEXT SIZE バーは `[9,10,11,12,14,16,20]` の7刻み)。
6. 倍率変更直後、開いていたパネルは閉じることがある(出力の作り直し)。
7. **画面共有から除外されている窓は grim で真っ黒に写る。** Bitwarden がそれ
   (`default/hypr/apps/bitwarden.lua` の `no_screen_share = true`)。
   パネル自体は除外されないので、この検証手順はそのまま使える。
   → [bitwarden.md](bitwarden.md)

## 撤去

```bash
omarchy plugin remove torohash.monitor --yes   # backup に退避 + omarchy.monitor に戻る
omarchy restart shell
```

倍率だけ元に戻すなら `omarchy hyprland monitor scaling 1.6`
(または `~/.config/hypr/monitors.lua` の `omarchy_monitor_scale` を書き換え)。

## 参考

- 実装: `/usr/share/omarchy/bin/omarchy-hyprland-monitor-scaling` (`clean_scale()` の根拠)
- スライダー: `/usr/share/omarchy/shell/Ui/PanelSlider.qml` (`tickCount` でノッチ)
- 元プラグイン: `/usr/share/omarchy/shell/plugins/panels/monitor/`
- [Hyprland Monitors](https://wiki.hypr.land/Configuring/Basics/Monitors/)
