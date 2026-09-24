# Display scale — 表示倍率と Display パネルのスライダー化

bar の Display パネル (bar widget `omarchy.monitor`) の表示倍率まわり。
**2x はでかすぎ / 1.6x はやや小さい**ので中間を使いたい、という要求に対して、
固定6プリセットの SCALE 行を**スライダー(11段)に作り替える**手順。

## 大前提: Hyprland が受け付ける倍率は飛び飛び

Hyprland の `monitor scale` は「モードが整数の論理ピクセルに割り切れる」値しか取れない。
実装は `gcd(width*120, height*120)` の約数 (`/usr/share/omarchy/bin/omarchy-hyprland-monitor-scaling`
の `clean_scale()`)。例えば **2880x1800 → gcd = 43200** なので:

```
1  1.125  1.2  1.25  1.333  1.5  1.6  1.667  1.8  1.875
2  2.25   2.4  2.5   2.667  3    3.333 3.6   3.75  4
```

**1.6〜2.0 の中間は 1.667 / 1.8 / 1.875 の3つだけ。** 1.7 や 1.75 を指定しても
近い有効値 (1.8) に切り上げられる。ボタンやスライダーを増やしても
**この制約は変わらない**ので、「段階を増やす」の実体は「有効値を全部見せる」こと。

- 論理サイズ: 1.6→1800x1125 / 1.667→1728x1080 / 1.8→1600x1000 / 1.875→1536x960 / 2→1440x900

## 何を変えるか

`/usr/share/omarchy/shell/plugins/panels/monitor/Panel.qml` は SCALE を
`scalePresets = ["1","1.25","1.6","2","3","4"]` の**6個のボタン**で描いている。
`omarchy plugin clone` で複製し、TEXT SIZE と同じ `PanelSlider` に置換する:

| 元 | 変更後 |
|----|--------|
| `Grid` + `Repeater` + `ScalePill` (6ボタン) | `CursorSurface` + `PanelSlider` (11ノッチ) |
| 6プリセット固定 | `["1","1.25","1.5","1.6","1.667","1.8","1.875","2","2.5","3","4"]` |
| ヘッダー右 = モニタ名のみ | 倍率の値 (`1.8x`) + 複数ディスプレイ時はモニタ名 |
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

# 4. 倍率を設定 (数値指定。`up`/`down` は 1.6→2 に飛ぶので不可)
omarchy hyprland monitor scaling 1.8
```

`assets/torohash.monitor/` には `Panel.qml` の他に `Model.js` / `manifest.json` も
置いてある(複製直後と同一内容。丸ごと `cp -r` してもよい)。

## 検証 (期待される出力)

```bash
hyprctl monitors -j | jq '.[0].scale'                    # => 1.8
omarchy-shell omarchy.monitor state | jq -r .scale       # => 1.8

# アプリ側が追従しているか (Chromium の例): DPR が monitor scale と一致するはず
#   chromium --user-data-dir=/tmp/dpr --remote-debugging-port=9333 about:blank &
#   curl -s http://127.0.0.1:9333/json  →  webSocketDebuggerUrl に Runtime.evaluate で
#   devicePixelRatio を問い合わせる (1.8 なら追従している)

# 段の一覧とライブ値 → 段番号の対応 (Model.js を node で直接実行)
node -e '...'          # available: ["1","1.25","1.5","1.6","1.667","1.8","1.875","2","2.5","3","4"] count=11
                       # 1.6 -> index 3 / 1.8 -> index 5 / 1.875 -> index 6

# パネルの見た目 (grim + magick で切り出して確認)
omarchy-shell omarchy.monitor open && grim /tmp/panel.png
magick /tmp/panel.png -crop 720x1250+2160+0 +repage /tmp/crop.png
# => SCALE 行が 11ノッチのスライダー、ヘッダー右が現在の倍率に追従

# プラグインの健全性 / QML エラー
omarchy plugin validate ~/.config/omarchy/plugins/$(whoami).monitor   # => exit 0
tr -c '[:print:]\n' '\n' < /run/user/1000/quickshell/by-id/*/log.qslog \
  | grep -iE "TypeError|ReferenceError|Binding loop"                 # => 何も出ない
```

## ハマりどころ

1. **QML の変更は hot-reload では効かない。** journal には
   `DEBUG qml: Local plugin changed, reloading: <plugin>` と出るのに、
   開いたパネルは**旧 UI (6ボタン) のまま**になる。`omarchy restart shell` で直る。
   ローカルプラグインを触ったら再起動まで疑うこと。
2. `/usr/share/omarchy/` は**編集禁止**(`omarchy update` で消える)。
   `omarchy plugin clone` で `~/.config/omarchy/plugins/` に複製してから触る。
3. 段を増やしても**有効値は増えない**(先頭の割り切れ制約)。
4. **アプリの「内部サイズ」は変わらない。** `monitor scale` が変えるのは
   「論理ピクセル ↔ 物理ピクセル」の対応だけで、アプリから見た `devicePixelRatio` が
   scale に追従する (計測例: scale=1.6 → DPR 1.6 / 1.8 → 1.8 / 2 → 2)。
   - Wayland アプリは fractional scale に完全追従する。Chromium / Electron は
     `wp_fractional_scale_v1` を使う (DPR が 1.8 など小数になる)。GTK4 も
     `Gdk.Monitor.get_scale()` が 1.8 を返す (`get_scale_factor()` は整数の 2)。
   - 変わらないのは**アプリ内部の設定**: CSS px、ページズーム (100%)、UI フォントサイズ、
     アプリ独自のズーム。アプリは再レイアウトしないので「内部の表示サイズが変わった」
     ようには見えない。物理的な大きさは scale の比だけ変わる (1.6→1.8 なら +12.5%)。
   - **`GDK_SCALE` は Wayland では効かない。** 設定しても GTK の `get_scale()` は
     compositor の scale のまま (`GDK_SCALE=2` と unset で同じ値になる)。
     `monitors.lua` の `omarchy_gdk_scale` は XWayland / 旧来の X11 アプリ用の安全弁
     (`xwayland:force_zero_scaling` が true の環境で、X11 アプリが豆粒になるのを防ぐ)。
   - 個別アプリの内部サイズを変えたいときは、そのアプリのレバーを使う:
     Chromium → ページズーム (`Ctrl+=`) か `--force-device-scale-factor=1.25` を
     `~/.config/chromium-flags.conf` に追記。Bitwarden / Electron → アプリ内の
     Zoom、または同じ `--force-device-scale-factor`。
     GTK・シェル・ターミナル → `omarchy display text size`。
5. 文字だけを細かく詰めたいなら別系統のレバーがある:
   `omarchy display text size 13` (shell base-size / GTK factor / terminal pt を同時に変更。
   9〜20px の整数全部を受ける。パネルの TEXT SIZE バーは `[9,10,11,12,14,16,20]` の7刻み)。
6. 倍率変更直後、開いていたパネルは閉じることがある(出力の作り直し)。
7. **画面共有から除外されている窓は grim で真っ黒に写る。** Bitwarden がそれ
   (`default/hypr/apps/bitwarden.lua` の `no_screen_share = true`)。
   パネル自体は除外されないので、この検証手順はそのまま使える。
   → [bitwarden.md](bitwarden.md)

## 元に戻す

```bash
omarchy plugin remove torohash.monitor --yes   # backup に退避 + omarchy.monitor に戻る
omarchy restart shell
```

倍率だけ戻すなら `omarchy hyprland monitor scaling 1.6`
(または `~/.config/hypr/monitors.lua` の `omarchy_monitor_scale` を書き換え)。

## 参考

- 実装: `/usr/share/omarchy/bin/omarchy-hyprland-monitor-scaling` (`clean_scale()` の根拠)
- スライダー: `/usr/share/omarchy/Ui/PanelSlider.qml` (`tickCount` でノッチ)
- 元プラグイン: `/usr/share/omarchy/shell/plugins/panels/monitor/`
- [Hyprland Monitors](https://wiki.hypr.land/Configuring/Basics/Monitors/)
