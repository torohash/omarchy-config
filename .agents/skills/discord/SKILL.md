---
name: discord
description: Discord の公式クライアントを入れ、Omarchy の Web アプリ版ランチャーと重複しないようにする。Discord を導入・確認するとき、ランチャーに Discord が 2 つ並ぶときに使う。
metadata:
  privilege: sudo
  depends: none
---

# Discord (公式クライアント)

`extra` の `discord` を入れる (AUR 不要)。Omarchy は Web アプリ版のランチャー (`Discord.desktop`) を
最初から持っているので、そちらを消して 1 つにする。理由とハマりどころ (MFA 等) は [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
pacman -Q discord >/dev/null && [ ! -e ~/.local/share/applications/Discord.desktop ] && echo "discord: ok"
```

## 特権で行う操作

```bash
omarchy pkg add discord
```

## 実行

```bash
[ -e ~/.local/share/applications/Discord.desktop ] && omarchy webapp remove Discord
```

## ユーザーに頼む操作

`discord` を起動してログインしてもらう。**初回起動で本体 (約 500MB) をダウンロードする**ので、ネット接続が要る。
MFA がパスキー / セキュリティキーだとアプリでは失敗する。「Verify with something else」で TOTP かバックアップコード、
または QR コードログインを使う (詳細は reference.md)。

## 検証

```bash
pacman -Q discord                                            # => discord 1:1.0.x-x
ls ~/.local/share/applications/Discord.desktop 2>&1          # => No such file or directory
```

## 元に戻す

```bash
omarchy pkg drop discord
rm -rf ~/.config/discord                                     # 初回に落とした本体
omarchy webapp install Discord https://discord.com/channels/@me omarchy-discord   # Web アプリ版を戻すなら
```
