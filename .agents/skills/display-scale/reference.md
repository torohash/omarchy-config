# Display scale — 理由・倍率の制約・ハマりどころ

手順は [SKILL.md](SKILL.md)。

## Hyprland が受け付ける倍率は飛び飛び

Hyprland の monitor scale は「モードが整数の論理ピクセルに割り切れる」値しか取れない。
実装は `gcd(width*120, height*120)` の約数 (`/usr/share/omarchy/bin/omarchy-hyprland-monitor-scaling` の `clean_scale()`)。
2880x1800 なら gcd = 43200 で、選べるのは次の値。

```
1  1.125  1.2  1.25  1.333  1.5  1.6  1.667  1.8  1.875
2  2.25   2.4  2.5   2.667  3    3.333 3.6   3.75  4
```

1.6〜2.0 の中間は 1.667 / 1.8 / 1.875 の 3 つだけ。1.7 などを指定すると近い有効値に丸められる。
論理サイズ: 1.5→1920x1200 / 1.6→1800x1125 / 1.8→1600x1000 / 2→1440x900。

## 何を変えるか

`/usr/share/omarchy/shell/plugins/panels/monitor/Panel.qml` の SCALE は 6 個のボタン。複製して `PanelSlider` に置き換える。

| 元 | 変更後 |
|----|--------|
| `Grid` + `Repeater` + `ScalePill` (6 ボタン) | `CursorSurface` + `PanelSlider` (11 ノッチ) |
| 6 プリセット固定 | `["1","1.25","1.5","1.6","1.667","1.8","1.875","2","2.5","3","4"]` |
| ヘッダーの右 = モニタ名 | 倍率 (`1.8x`) + 複数ディスプレイならモニタ名 |
| j/k でボタン、h/l でプリセット | h/l で 1 段ずつ |

`Model.availableScales()` が解像度に合わない値を捨てるので、他の解像度では自動で間引かれる。
クリックで確定したときだけ `omarchy-hyprland-monitor-scaling <値>` を実行する (ドラッグ中は実行しない)。
`Model.js` と `manifest.json` は複製のまま使う (改造するのは `Panel.qml` だけ)。

## ハマりどころ

1. **QML の変更は hot-reload では効かない**: journal に `Local plugin changed, reloading` と出ても旧 UI のまま。`omarchy restart shell` で直る。
2. `/usr/share/omarchy/` は編集しない。`omarchy plugin clone` で `~/.config/omarchy/plugins/` に複製してから触る。
3. 段を増やしても有効な倍率は増えない (上の制約)。
4. **アプリの内部のサイズは変わらない**: 倍率が変えるのは論理ピクセルと物理ピクセルの対応だけ。アプリの `devicePixelRatio` が倍率に追従する。
   - Chromium / Electron / GTK4 は fractional scale に追従する。`GDK_SCALE` は Wayland では効かない
     (`monitors.lua` の `omarchy_gdk_scale` は XWayland / X11 アプリ用)。
   - アプリ単位で変えたいときは、そのアプリのズームか `--force-device-scale-factor`。GTK・shell・端末は `omarchy display text size`。
5. 文字だけを細かく変えるなら `omarchy display text size <9〜20>`。
6. 倍率を変えた直後、開いていたパネルが閉じることがある (出力の作り直し)。
7. 倍率は `omarchy refresh hyprland` で既定に戻る (`~/.config/hypr/monitors.lua` の `omarchy_monitor_scale`)。

## 参考

- スライダー: `/usr/share/omarchy/Ui/PanelSlider.qml` (`tickCount` でノッチ)
- 元のプラグイン: `/usr/share/omarchy/shell/plugins/panels/monitor/`
- [Hyprland Monitors](https://wiki.hypr.land/Configuring/Basics/Monitors/)
