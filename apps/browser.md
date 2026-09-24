# Browser — 使っているブラウザ

**このホストの選択: Chromium(Omarchy のベースに含まれる既定のまま。追加インストールも変更も無し)。**

## 候補と、選ぶときに効く違い

Omarchy が用意しているのは次の6つ(Install > Browser、または `omarchy install browser <name>`):

| 候補 | こんなとき | Omarchy のテーマ / 拡張 / Web アプリ* |
|------|-----------|-----------------------------------|
| **Chromium**(既定) | 何もしなくてよい | ◯ |
| Chrome | Google アカウント連携が要る | ◯ |
| Edge | Edge 固有機能が要る | ◯ |
| Brave | 広告ブロック / privacy 優先 | ◯ |
| Brave Origin | Brave から crypto・rewards を外した版 | ◯ |
| Firefox | Gecko を使いたい | ✗ |
| Zen | Firefox ベースで見た目重視 | ✗ |

\* Web アプリ (`omarchy-launch-webapp`) は Chromium 系でしか開かない。
Firefox / Zen を既定にしても Web アプリは Chromium のままなので、**chromium は残す**。
テーマ色の連携と Omarchy 拡張(Copy URL / yt-dlp)も Chromium 系のみ
(Firefox / Zen には Wayland ネイティブ化と既定値ポリシーだけが入る)。

## 変更 / 撤去

```bash
omarchy default browser              # 現在の既定を表示
omarchy default browser firefox      # 変更 (XDG ハンドラごと差し替わる)
omarchy install browser firefox      # 導入 (sudo が要るので端末で実行)
omarchy remove browser firefox       # 撤去 (既定なら chromium に戻す処理込み)
```
