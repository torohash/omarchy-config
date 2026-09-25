---
name: herdr
description: herdr (Omarchy 同梱のターミナルワークスペースマネージャ) のキー割り当てを、左手だけで操作できる設定 (prefix alt+s、A/D で workspace・agent 移動) にする。herdr のキー設定を適用・確認・修正するとき、omarchy refresh herdr で設定が戻ったときに使う。
metadata:
  privilege: none
  depends: none
---

# herdr のキー割り当て

herdr 純正のキーを土台に、prefix と移動キーを左手だけで押せるものにする。
Omarchy 版の既定 (prefix `ctrl+space`) は fcitx5 の IME 切替と衝突する。理由と経緯は [reference.md](reference.md)。

| 操作 | キー |
|------|------|
| prefix | `alt+s` |
| 前 / 次の workspace | `prefix+a` / `prefix+d` |
| 前 / 次の agent | `prefix+shift+a` / `prefix+shift+d` |
| workspace を閉じる | `prefix+shift+q` (純正は `prefix+shift+d`) |

## 確認 (済んでいれば「実行」を飛ばす)

```bash
diff <(sed -n '/^\[keys\]/,$p' ~/.config/herdr/config.toml | grep -v -e '^#' -e '^$') \
     <(grep -v -e '^#' -e '^$' ~/dev/config/.agents/skills/herdr/files/keys.toml) \
  && echo "herdr keys: ok"
```

## 実行

1. 現在の設定を退避する。

   ```bash
   mkdir -p ~/.local/state/omarchy-config/backups
   cp ~/.config/herdr/config.toml ~/.local/state/omarchy-config/backups/herdr-config.toml.$(date +%s)
   ```

2. キーを herdr 純正に戻す。`[keys]` 以外 (Omarchy の `[theme]` `[ui]` など) は残る。

   ```bash
   herdr config reset-keys
   ```

3. 新しいキー割り当てを末尾に追記して反映する。

   ```bash
   printf '\n' >> ~/.config/herdr/config.toml
   cat ~/dev/config/.agents/skills/herdr/files/keys.toml >> ~/.config/herdr/config.toml
   herdr config check            # => config: ok
   herdr server reload-config    # => {..."status":"applied"...}
   ```

## 検証

```bash
omarchy-menu-herdr-keybindings --print | grep -E '^PREFIX +→|workspace$|agent$'
# => PREFIX                           → ALT + S
#    PREFIX + SHIFT + Q               → Close workspace
#    PREFIX + A                       → Previous workspace
#    PREFIX + D                       → Next workspace
#    PREFIX + SHIFT + A               → Previous agent
#    PREFIX + SHIFT + D               → Next agent

# 同じキーが 2 つの操作に割り当たっていないこと (出力が空)
omarchy-menu-herdr-keybindings --print | awk -F'→' '{gsub(/ +$/,"",$1); print $1}' | sort | uniq -d
```

「確認」のコマンドも `herdr keys: ok` を出す。

## 元に戻す

```bash
omarchy refresh herdr        # Omarchy の既定 (prefix ctrl+space) に戻る
```
