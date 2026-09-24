# Voxtype — 音声入力(ディクテーション)

Omarchy 4.0.4 の初回通知「Install Dictation with Voxtype」から入る、
**プッシュ・トゥ・トークの音声→文字入力**ツール。Rust + whisper.cpp。**ローカル推論のみ**(クラウド無し)。

- 公式: [voxtype.io](https://voxtype.io)
- パッケージ: `voxtype-bin`(Omarchy リポジトリ, v1.0.1)+ `wtype`
- 設定: `~/.config/voxtype/config.toml`
- モデル: `~/.local/share/voxtype/models/`
- 常駐: systemd ユーザーサービス `voxtype.service`

## 導入

```bash
omarchy voxtype install     # 通知をクリックしても同じ
```

内部でやっていること (`omarchy-voxtype-install`):
`omarchy-pkg-add wtype voxtype-bin` → 既定 config をコピー → `voxtype setup --download --no-post-install`
→ Vulkan があれば `voxtype setup gpu --enable` → `voxtype setup systemd` → `hyprctl reload` → シェル再起動。

### サイズの内訳 (634MB の正体)

| 内容 | サイズ |
|------|--------|
| `cuda-13` | 254M |
| `cuda-12` | 140M |
| `voxtype-vulkan` | 62M |
| `migraphx`(AMD) | 47M |
| `voxtype-onnx-avx2/avx512` | 43M ×2 |
| `voxtype-avx2/avx512` | 18M ×2 |
| `voxtype-osd*` | 7M |

**モデルは1バイトも含まれない。** GPU バックエンド(の詰め合わせ)が重さの理由。

## ⚠️ 既定は英語専用(ハマりどころ筆頭)

Omarchy の既定 config はこれ:

```toml
model = "base.en"   # .en = 英語専用モデル
language = "en"
```

→ **日本語で喋ると、無理やり英文として書き起こされて意味不明な英語になる。**
（「英語になっちゃった」の原因はこれ。Omarchy の通知から入れると必ずこうなる）

## 日本語化

モデルと言語の**両方**を変える必要がある。

```bash
# 1. 多言語モデルを取得 + そのモデルへ切替
voxtype setup --download --model small --activate

# 2. 言語を日本語に
voxtype config set whisper.language ja

# 3. 無音の幻覚対策 (VAD)
voxtype setup vad                          # Silero VAD (0.8MB)
voxtype config set vad.enabled true
voxtype config set vad.backend whisper

# 4. 反映
systemctl --user restart voxtype
```

### モデルの選択肢

| モデル | サイズ | 用途 |
|--------|--------|------|
| `tiny.en` | 39 MB | 英語・最速 |
| `base.en` | 142 MB | 英語・既定 |
| `base` | 142 MB | 多言語・速い |
| **`small`** | **466 MB** | **多言語・推奨バランス** |
| `medium` | 1.5 GB | 多言語・高精度 |
| `large-v3-turbo` | 1.6 GB | 多言語・高精度/高速 |
| `large-v3` | 3.1 GB | 多言語・最高精度 |
| ONNX(Parakeet 等) | 198MB〜3.9GB | 別エンジン。`voxtype setup onnx` |

## GPU 加速 (Vulkan)

```bash
sudo voxtype setup gpu --enable     # /usr/bin/voxtype を voxtype-vulkan に張り替え
voxtype setup gpu --status          # 現在のバックエンド
sudo voxtype setup gpu --disable    # CPU に戻す
```

期待される出力:

```
Active backend: GPU (Vulkan)
  1. [Intel] Core Ultra 200V Series Processors Arc Graphics 130V/140V GPU
```

`vulkan-icd-loader` / `vulkan-intel` が必要 (GPU を使う場合)。

## VAD(無音区間の幻覚対策) — 既定 OFF

Whisper は無音や雑音区間で**幻覚(でたらめな文字列)**を出しやすい。
`vad.enabled` の既定値は **false** なので、長めに録音すると起きる。

```bash
voxtype setup vad                                   # ggml-silero-vad.bin (0.8MB)
voxtype config set vad.enabled true
voxtype config set vad.backend whisper              # auto / energy / whisper
```

## 操作

| 操作 | キー |
|------|------|
| 押している間だけ録音 | **`F9`** |
| 録音のトグル | **`Super+Ctrl+X`** |

- バーの Dictation インジケーターが録音状態を表示 (`omarchy-voxtype-status`)
- 出力は `wtype` でカーソル位置に直接入力(CJK 対応)
- `Hotkey` は設定で `enabled = false`(Hyprland 側でキーを束ねているため)

## コマンド

```bash
voxtype setup check                 # システム診断
voxtype setup model --list          # 導入済みモデル
voxtype setup model                 # 対話でモデル選択
voxtype setup gpu --status          # GPU バックエンド
voxtype setup vad --status          # VAD モデル
voxtype config schema               # 全設定キー
voxtype config get whisper.model
voxtype config set whisper.language ja
voxtype transcribe file.wav         # ファイルを文字起こし (16kHz mono WAV)
voxtype record start|stop|toggle    # 外部から録音制御
systemctl --user restart voxtype
```

## 喋らずに動作確認する方法

Wikimedia Commons の日本語音声を使ってテストできる。

```bash
curl -sL "https://upload.wikimedia.org/wikipedia/commons/d/d2/Ja-Densha_2.oga" -o /tmp/a.ogg
ffmpeg -y -i /tmp/a.ogg -ar 16000 -ac 1 /tmp/a.wav
voxtype transcribe /tmp/a.wav
# => 電車   (Vulkan なら 4 秒前後)
```

## モデルの選定 (精度・速度の比較)

テスト音源: Wikimedia [Ja-Na-adjectives_watch_and_listen.ogg](https://commons.wikimedia.org/wiki/File:Ja-Na-adjectives_watch_and_listen.ogg)
(65.6 秒の明瞭な日本語 / な形容詞の練習)

| モデル | 処理時間 | 速度 | 結果 |
|--------|---------|------|------|
| **`small`** (466MB) | **3.05 s** | **21x realtime** | **全問正解 + 句読点あり** |
| `large-v3-turbo` (1.5GB) | 5.66 s | 11x realtime | 「宿題だ」を**重複**、句読点なし |

**結論: 大きいモデルが常に良いわけではない。** 明瞭な日本語なら `small` で十分で、
比較では `small` のほうが速く、繰り返しの誤りも出にくかった。

> **採用: `small`。** 比較の結果 `large-v3-turbo` を使う理由が見つからないので、
> 入れる必要はない。再度試したくなったら
> `voxtype setup --download --model large-v3-turbo --activate`。

### 誤変換の傾向と対策

| 症状 | 例 | 対策 |
|------|-----|------|
| **同音異義語の取り違え** | 「青巻紙」→「青巻き髪」(どちらも まきがみ) | 音響ではなく**語彙の問題**。`whisper.initial_prompt` で文脈を与える |
| 早口言葉 | 「生麦生米生卵」→「生むきのもごめんなま玉子」 | 人間でも難しい。無理 |
| 無音区間のでたらめ | 「雪外外外外外…」 | VAD を有効化(既定 OFF) |

### 精度を上げる手順(優先順)

1. `whisper.initial_prompt` に分野の語彙を入れる(最も効く・タダ)
   ```bash
   voxtype config set whisper.initial_prompt "専門用語や固有名詞、よく使う単語をここに"
   systemctl --user restart voxtype
   ```
2. マイクを見直す(内蔵よりヘッドセット/外付けが有利)
3. 早口をやめる・区切って話す
4. どうしても必要なときだけ `--model large-v3-turbo`

> v1.0.1 には**単語置換(text replacement)機能が無い**。1.1.0 で追加された
> (「text rules everywhere」)。Omarchy リポジトリの更新を待つ。

### 高精度モデルを「必要なときだけ」使う

`voxtype record start` は `--model` を受け付けるので、キーを分けられる:

```bash
voxtype record start --model large-v3-turbo   # 高精度で録音開始
```

Hyprland 側 (`~/.config/hypr/bindings.lua`) に `SHIFT + F9` を足せば
「F9=高速 / Shift+F9=高精度」にできる(※ F9 の release バインドと干渉しないか要検証)。

## 適用する設定

```toml
[whisper]
model = "small"            # 比較の結果これを採用
language = "ja"

[vad]
enabled = true
backend = "whisper"
```

- バックエンド: **GPU (Vulkan)** / Intel Arc 130V/140V
- `voxtype setup check` → All checks passed
- 日本語テスト: 「電車」→ `電車` ✅

> `setup check` の警告: ユーザーが `input` グループに入っていないため evdev ホットキーと
> modifier-release guard は無効。Omarchy は **compositor(Hyprland)側のキーバインド**を
> 使うので実害なし。

## OpenWhispr との比較(参考)

| | OpenWhispr | Voxtype |
|---|---|---|
| 実体 | Electron GUI アプリ (MIT) | Rust CLI + デーモン |
| クラウド | BYOK / 独自クラウド(サインイン) | **無し(ローカルのみ)** |
| 機能 | 議事録・ノート・AIエージェント・話者分離・検索・MCP | 音声→カーソル入力のみ |
| 導入 | AUR `openwhispr-bin` / AppImage(手動更新) | **Omarchy リポジトリ**(更新が乗る) |
| 統合 | 独自ホットキー + トレイ | Omarchy 統合(F9/Super+Ctrl+X、バー、systemd) |
| アプリ本体 | 約184MB | 634MB(多バックエンド同梱) |
| メモリ | Electron で重め | 軽い |

同じモデルを使えば認識結果はほぼ同じ(どちらも whisper.cpp)。違いは機能と統合。
**併用するとホットキーが衝突する**点に注意。

## 撤去

```bash
omarchy voxtype remove
```
