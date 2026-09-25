# OpenWhispr — 理由・Voxtype との比較・ハマりどころ

手順は [SKILL.md](SKILL.md)。公式: [OpenWhispr/openwhispr](https://github.com/OpenWhispr/openwhispr)。

## 入れる理由

**会議の議事録を取るため**。Zoom / Teams などの会議を自動で検出し、話者を区別して文字にし、メモにまとめる。
話者の区別はローカルで動く。音声入力 (キーで録音してカーソル位置に入力) や翻訳入力もできる。
サインインは任意 (共有・同期に使う)。ローカルのモデル (whisper 系、Parakeet など) で全機能が動く。

## Voxtype との比較

| 観点 | Voxtype | OpenWhispr |
|------|---------|------------|
| 議事録 | できない | **できる** (話者の区別・メモ) |
| Omarchy との統合 | Omarchy のリポジトリから入り更新される。F9 / `Super+Ctrl+X`、バーの録音表示が最初からある | 無し。AUR から入れ、キーは Hyprland で用意する |
| 重さ | Rust の常駐プロセス | Electron のアプリ |
| 認識の精度 | whisper.cpp | 同じモデルならほぼ同じ |

議事録には OpenWhispr が要る。音声入力をどちらでするかは、Hyprland での使い勝手を試して決める
(OpenWhispr で足りれば Voxtype を外してアプリを 1 つにできる)。両方を使うなら、キーを分けて衝突させない
(Voxtype = F9 / `Super+Ctrl+X`、OpenWhispr = `Super+Shift+K` / `Super+Shift+J`)。

## D-Bus で呼ぶ

OpenWhispr は `com.openwhispr.App` (`/com/openwhispr/App`) を公開している。メソッドは次の 4 つ。

| メソッド | 操作 |
|---------|------|
| `Toggle` | 音声入力の開始 / 停止 |
| `ToggleMeeting` | 議事録の開始 / 停止 |
| `ToggleTranslation` | 翻訳入力 |
| `ToggleVoiceAgent` | 音声エージェント |

OpenWhispr 自身のグローバルキーは GNOME のショートカットやポータルを使う作りで、Hyprland では効かないことがある。
Hyprland の `o.bind` から `dbus-send` で呼ぶ。起動していなければ `dbus-send` が失敗するので、そのときは起動する。

```bash
dbus-send --session --type=method_call --dest=com.openwhispr.App /com/openwhispr/App com.openwhispr.App.ToggleMeeting
```

## キー選び

`Super+Shift+M` は Omarchy の Music、`Super+Ctrl+K` は Herdr keybindings、`Super+Alt+K` は Tmux keybindings が使っている。
議事録は `Super+Shift+J` (音声入力の K の隣) にする。空いているかは `hyprctl binds -j` で確かめる (add-task のルール)。

OpenWhispr 自身のキーの登録画面では、Hyprland に割り当てたキーは押しても入らない (Hyprland が先に受け取る)。
OpenWhispr は XWayland (`--ozone-platform=x11`) で動いていて、X11 のグローバルなキーの横取りは
XWayland のウィンドウにフォーカスがあるときしか効かない。なので Hyprland のキーから D-Bus で呼ぶ。

## 入力の経路

AUR の `openwhispr-bin` は、入力に `wtype` / `ydotool` / `xdotool` を任意で使う。Omarchy は `wtype` を入れている。
他のホスト (GNOME) では `ydotool` を使い、`/dev/uinput` の権限不足 (`Permission denied`) で入力できないことがあった。
Hyprland では `wtype` で入力できれば `ydotool` は要らない。

## 未確認の点

- **会議の相手の声 (システム音声) を議事録に入れられるか**。公式の説明に Linux での扱いが書かれていない。
  PipeWire で相手の声まで録れるかを実際に確かめる。
- Hyprland で `wtype` による入力が問題なく動くか。
