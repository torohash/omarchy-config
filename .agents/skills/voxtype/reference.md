# Voxtype — 理由・モデルの比較・ハマりどころ

手順は [SKILL.md](SKILL.md)。

Omarchy の音声入力。押している間だけ録音して文字にし、`wtype` でカーソル位置に入力する。
Rust + whisper.cpp で、**推論はローカルだけ** (クラウドに送らない)。

- パッケージ: `voxtype-bin` (Omarchy のリポジトリ) + `wtype`
- 設定: `~/.config/voxtype/config.toml` / モデル: `~/.local/share/voxtype/models/`
- 常駐: systemd のユーザーサービス `voxtype.service`
- 公式: [voxtype.io](https://voxtype.io)

## Omarchy のインストーラーとの関係

`omarchy voxtype install` (`omarchy-voxtype-install`) は、`gum confirm` で確認 → `omarchy-pkg-add wtype voxtype-bin` →
既定の config をコピー → `voxtype setup --download --no-post-install` (英語の `base.en` を落とす) →
Vulkan があれば `voxtype setup gpu --enable` → `voxtype setup systemd` → `hyprctl reload` → shell 再起動。

SKILL.md は、sudo が要る部分 (パッケージと GPU) を特権の操作に分け、既定の英語モデルは落とさずに `small` を入れる。
この分け方は、インストーラーの中身から組み立てたもの。新しい環境で問題があれば、
`omarchy voxtype install` を実行してから「実行」の日本語化の部分だけを行う。

## 既定は英語専用

```toml
model = "base.en"   # .en は英語専用のモデル
language = "en"
```

日本語で話すと、無理やり英文として書き起こされる。モデルと言語の両方を変える必要がある。

## モデルの比較

| モデル | サイズ | 用途 |
|--------|--------|------|
| `base.en` | 142 MB | 英語・Omarchy の既定 |
| `base` | 142 MB | 多言語・速い |
| **`small`** | **466 MB** | **多言語・採用** |
| `medium` | 1.5 GB | 多言語・高精度 |
| `large-v3-turbo` | 1.6 GB | 多言語・高精度 / 高速 |
| `large-v3` | 3.1 GB | 多言語・最高精度 |

65.6 秒の明瞭な日本語 (Wikimedia の Ja-Na-adjectives_watch_and_listen.ogg) で比べた結果:

| モデル | 処理時間 | 結果 |
|--------|---------|------|
| **`small`** | 3.05 秒 (21 倍速) | 全問正解 + 句読点あり |
| `large-v3-turbo` | 5.66 秒 (11 倍速) | 「宿題だ」を重複、句読点なし |

大きいモデルが常に良いわけではない。明瞭な日本語なら `small` で足りる。

## 精度を上げる手順 (効く順)

1. `voxtype config set whisper.initial_prompt "分野の語彙や固有名詞"` (同音異義語の取り違えに効く)
2. マイクを見直す (内蔵より外付けやヘッドセット)
3. 区切って話す
4. どうしても必要なときだけ大きいモデル (`voxtype record start --model large-v3-turbo` でキーを分けることもできる)

v1.0.1 には単語の置換機能が無い (1.1.0 で追加)。

## ハマりどころ

- **VAD は既定で無効**: 無音や雑音の区間で「雪外外外外…」のようなでたらめを出す。
- `voxtype setup check` の「input グループに入っていない」警告は無視してよい (Omarchy は Hyprland 側のキーを使う)。
- アプリ本体が大きい (634MB) のは GPU バックエンドの詰め合わせのため (CUDA 12 / 13、Vulkan など)。モデルは含まない。
- OpenWhispr などほかの音声入力と併用するとホットキーが衝突する。
