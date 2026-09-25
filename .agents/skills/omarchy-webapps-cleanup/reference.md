# 使わない Omarchy の Web アプリ — 理由・仕組み

手順は [SKILL.md](SKILL.md)。

## HEY と Basecamp

どちらも Omarchy の作者 DHH が共同創業した 37signals のサービス。

| 名前 | 何か | Omarchy での扱い |
|------|------|-----------------|
| HEY | 有料のメールサービス (カレンダー HEY Calendar を含む) | `Super+Shift+E` = Email、`Super+Shift+C` = Calendar、`Super+Shift+Alt+E` = New email。`mailto:` のリンクも HEY で開く (`HEY.desktop` → `omarchy-webapp-handler-hey`) |
| Basecamp | プロジェクト管理・共同作業のサービス | ランチャーだけ |

どちらもアプリを入れているのではなく、Chromium のアプリ用ウィンドウで開く Web アプリのランチャー (`~/.local/share/applications/*.desktop`)。
常駐はしないので負担はないが、使わないキーを押すと HEY のログイン画面が開くので外す。

## 仕組みとハマりどころ

- キーは `/usr/share/omarchy/default/hypr/bindings/applications.lua` にある。`hl.unbind` で打ち消す (Bitwarden と同じやり方)。
- `omarchy webapp remove <名前>` は `.desktop` とアイコンを消すだけで、`~/.config/mimeapps.list` の
  `x-scheme-handler/mailto=HEY.desktop` は残る (存在しないアプリを指す)。行を消す。
- `omarchy remove preinstalls` でも消せるが、Web アプリ以外の TUI やパッケージまで消すので使わない。
- `omarchy install preinstalls` を実行すると HEY / Basecamp が戻る。
- `Super+Ctrl+Alt+D` の Calendar はバーの時計のカレンダー (HEY ではない) なので残す。
