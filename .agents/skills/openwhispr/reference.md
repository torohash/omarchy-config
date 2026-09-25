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
| Omarchy との統合 | Omarchy のリポジトリから入り更新される。F9 / `Super+Ctrl+X`、バーの録音表示が最初からある | 無し。AUR から入れ、キーはアプリで決める |
| 重さ | Rust の常駐プロセス | Electron の GUI アプリ (トレイに常駐) |
| 認識の精度 | whisper.cpp | 同じモデルならほぼ同じ |

議事録には OpenWhispr が要る。両方を使うなら、キーを分けて衝突させない (Voxtype = F9 / `Super+Ctrl+X`)。

## 責務: インストールまで

キーやモデルは、どうせ初期設定でアプリが聞いてくるので、skill ではインストールだけを行い、設定はユーザーに任せる。
Hyprland のキーから D-Bus で呼ぶ仕組みも試したが、アプリ側のキーと二重になって分かりにくいので入れない
(アプリ側のキーで困ったら、下の D-Bus を Hyprland の `o.bind` から呼べる)。

## アプリを開くキー

`Super+Shift+V` (Voice)。Omarchy は `Super+Shift+<英字>` をアプリの起動に使っている (O = Obsidian など)。
`{ launch = "openwhispr" }` だけにして `focus` は付けない。起動済みで `openwhispr` を実行すると既存のコントロールパネルが開くため。
`focus = "^open-whispr$"` にすると、同じウィンドウクラスの小さな録音パネル (「Voice Recorder」) に移動してしまう。

## アプリの形

- Electron の GUI アプリ。設定・メモ・議事録のコントロールパネルと、録音中の小さなパネルがある。トレイに常駐する。
- アプリ内に「ログイン時に起動」「最小化で起動」の設定がある。キーをすぐ使うにはオンにしておく。
- **XWayland (`--ozone-platform=x11`) で動く**。
- 設定と議事録は `~/.config/open-whispr/` (議事録は `transcriptions.db`)。

## キー選び

- 既定のキー (Linux) は音声入力の `Control+Super`。登録に失敗すると `F8` → `F9` → `Control+Shift+Space` の順に試す。
  **`F9` は Voxtype と同じ**なので、キーは明示的に登録する。
- Hyprland (Omarchy) が使っているキーは、アプリの登録画面では入らない。例: `Super+Shift+M` = Music、
  `Super+Ctrl+K` = Herdr keybindings、`Super+Alt+K` = Tmux keybindings。空きは `hyprctl binds -j` で確かめる。

## D-Bus で呼ぶ (必要なときだけ)

OpenWhispr は `com.openwhispr.App` (`/com/openwhispr/App`) を公開している。

| メソッド | 操作 |
|---------|------|
| `Toggle` | 音声入力の開始 / 停止 |
| `ToggleMeeting` | 議事録の開始 / 停止 |
| `ToggleTranslation` | 翻訳入力 |
| `ToggleVoiceAgent` | 音声エージェント |

```bash
dbus-send --session --type=method_call --dest=com.openwhispr.App /com/openwhispr/App com.openwhispr.App.ToggleMeeting
```

## 入力の経路

AUR の `openwhispr-bin` は、入力に `wtype` / `ydotool` / `xdotool` を任意で使う。Omarchy は `wtype` を入れている。
他のホスト (GNOME) では `ydotool` を使い、`/dev/uinput` の権限不足 (`Permission denied`) で入力できないことがあった。
Hyprland では `wtype` で入力できれば `ydotool` は要らない。

## 未確認の点

- **会議の相手の声 (システム音声) を議事録に入れられるか**。公式の説明に Linux での扱いが書かれていない。
  PipeWire で相手の声まで録れるかを実際に確かめる。
- Hyprland で `wtype` による入力が問題なく動くか。
