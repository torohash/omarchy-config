---
name: agent-photo-sync
description: Agent PhotoSync の PC 側 (スマホで撮った写真を同じ LAN の Pi / Claude Code に渡す受信側) を導入する。Pi の拡張と Claude Code の MCP サーバーを登録し (ツールは確認なしで使えるよう許可する)、ufw で LAN から mDNS と受信ポートを許可する。写真の受信を設定・確認するとき、スマホのアプリから PC が見えないときに使う。
metadata:
  privilege: sudo
  depends: none
---

# Agent PhotoSync (PC 側の受信)

[torohash/agent-photo-sync](https://github.com/torohash/agent-photo-sync) を `~/dev/agent-photo-sync` に置き、
Pi には拡張、Claude Code には MCP サーバーとして登録する。どちらもセッションの開始で待ち受け、終了で止まる。
スマホのアプリは導入済みの前提 (この手順では扱わない)。理由とハマりどころは [reference.md](reference.md)。

## 確認 (済んでいれば「実行」を飛ばす)

```bash
[ -d ~/dev/agent-photo-sync/node_modules ] \
  && pi list 2>/dev/null | grep -q 'dev/agent-photo-sync$' \
  && claude mcp get photosync >/dev/null 2>&1 \
  && jq -e '.permissions.allow // [] | index("mcp__photosync")' ~/.claude/settings.json >/dev/null 2>&1 \
  && grep -q -- '--dport 5353 ' /etc/ufw/user.rules \
  && grep -q -- '--dports 47800:47819 ' /etc/ufw/user.rules \
  && echo "agent-photo-sync: ok"
```

## ユーザーに頼む操作

**特権の操作の前に**、受信を許可する LAN を確かめてもらう。家などふだん使う Wi-Fi につながっている状態で、
次の出力 (例: `192.168.0.0/24`) を許可してよいか聞く。外出先の LAN なら中止する。

```bash
iface=$(ip route show default | awk '{print $5; exit}')
ip -o -4 route show dev "$iface" scope link proto kernel | awk '{print $1; exit}'
```

導入後、スマホを同じ Wi-Fi につなぎ、アプリの一覧にこの PC のセッションが出るか見てもらう。

## 特権で行う操作

今つながっている LAN からだけ、mDNS (UDP 5353) と受信ポート (TCP 47800〜47819) を許可する。
同じ規則が既にあれば ufw は追加しない (`Skipping adding existing rule`)。

```bash
iface=$(ip route show default | awk '{print $5; exit}')
lan=$(ip -o -4 route show dev "$iface" scope link proto kernel | awk '{print $1; exit}')
[ -n "$lan" ]
sudo ufw allow from "$lan" to any port 5353 proto udp comment 'Agent PhotoSync mDNS'
sudo ufw allow from "$lan" to any port 47800:47819 proto tcp comment 'Agent PhotoSync'
```

## 実行

1. リポジトリを取得し、固定された版の Node.js で依存を入れる (Flutter / Android の道具は PC 側では不要)。

   ```bash
   [ -d ~/dev/agent-photo-sync ] || git clone https://github.com/torohash/agent-photo-sync ~/dev/agent-photo-sync
   cd ~/dev/agent-photo-sync
   mise trust
   mise install node
   mise exec -- npm ci
   ```

2. Pi の拡張として登録する (全プロジェクトで有効。次に起動する Pi から読み込まれる)。

   ```bash
   pi list 2>/dev/null | grep -q 'dev/agent-photo-sync$' || pi install ~/dev/agent-photo-sync
   ```

3. Claude Code の MCP サーバーとして登録する (ユーザースコープ。次に起動する Claude Code から有効)。

   ```bash
   claude mcp get photosync >/dev/null 2>&1 || claude mcp add --scope user photosync -- \
     mise exec -C "$HOME/dev/agent-photo-sync" -- node packages/claude-code/src/server.ts
   ```

4. photosync の MCP ツールを、毎回確認せずに使えるよう許可する (`mcp__photosync` = このサーバーの全ツール)。
   `~/.claude/settings.json` は Omarchy と Claude Code も書くので、`permissions.allow` に足すだけにする。

   ```bash
   f=~/.claude/settings.json
   mkdir -p ~/.claude ~/.local/state/omarchy-config/backups
   [ -f "$f" ] && cp "$f" ~/.local/state/omarchy-config/backups/claude-settings.json.$(date +%s) || echo '{}' > "$f"
   tmp=$(mktemp "$f.XXXXXX")
   jq '.permissions.allow = ((.permissions.allow // []) + ["mcp__photosync"] | unique)' "$f" > "$tmp" \
     && chmod 0644 "$tmp" && mv "$tmp" "$f"
   ```

## 検証

```bash
claude mcp get photosync        # => Status: ✔ Connected / Args: exec -C /home/<user>/dev/agent-photo-sync -- node packages/claude-code/src/server.ts
pi list | grep agent-photo-sync # => ../../dev/agent-photo-sync
jq -c '.permissions.allow' ~/.claude/settings.json   # => [..., "mcp__photosync", ...]
grep -c -E -- '--dport 5353 |--dports 47800:47819 ' /etc/ufw/user.rules   # => 2 (ufw の規則)
```

使い方の確認: Pi では `/photosync status`、Claude Code では「PhotoSync の状態を見せて」(`photosync_status`)。
待ち受け中は `ss -ltn | grep ':478'` に受信ポートが出る。

## 元に戻す

```bash
pi remove ~/dev/agent-photo-sync
claude mcp remove photosync -s user
f=~/.claude/settings.json; tmp=$(mktemp "$f.XXXXXX")
jq '.permissions.allow -= ["mcp__photosync"]' "$f" > "$tmp" && chmod 0644 "$tmp" && mv "$tmp" "$f"
# ufw の規則は番号を確かめてから消す (sudo)
sudo ufw status numbered | grep 'Agent PhotoSync'
sudo ufw delete <番号>
```
