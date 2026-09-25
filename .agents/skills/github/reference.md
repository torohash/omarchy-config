# GitHub — 理由・ハマりどころ

手順は [SKILL.md](SKILL.md)。

## なぜホスト鍵を登録するか

ホスト鍵は「接続先が本物の GitHub であること」を確かめる鍵で、ユーザーの秘密鍵 (`~/.ssh/id_ed25519`) とは別物。
`gh auth login` による認証と、SSH のホスト鍵検証は独立している。`gh auth login` が済んでいても、
`known_hosts` に GitHub の鍵が無いと、非対話の `git push` や `ssh -o BatchMode=yes` は初回確認に答えられずに失敗する。

## 登録のしかた

`register-github-hostkey.py` は GitHub 公式の HTTPS API (`https://api.github.com/meta`) から Ed25519 の鍵を取り、
API が示す指紋と、鍵から計算した指紋を照合してから `known_hosts` に追記する。信頼の根拠は HTTPS の証明書検証。
未検証の `ssh-keyscan` の出力はそのまま信用しない。

- `known_hosts` が無ければ権限 `600` で作る。あれば `~/.local/state/omarchy-config/backups/` に退避してから追記する。
- github.com の行が既にあれば何もしない。symlink なら止まる。

## ハマりどころ

- **`Host key verification failed` だけでは鍵の不一致とは限らない**。`known_hosts` が無いことが多い。
- ホスト鍵の検証はユーザー認証より先に行われる。この段階の失敗を、秘密鍵やリポジトリ権限の問題と混同しない。
- **`StrictHostKeyChecking=no` で回避しない**。検証を有効にしたまま公式の鍵を登録する。
- 既存の鍵と**一致しない**警告が出たら、鍵を消して回避せず原因を調べる。
- 通常の SSH 接続のあと、`UpdateHostKeys` により RSA / ECDSA のホスト鍵も自動で追加されることがある。
- **秘密鍵・`known_hosts` をリポジトリにコピーしない** (`known_hosts` には他の接続先も入る)。
- `gh auth login` で SSH を選ぶと、`gh` の git 操作のプロトコルが `ssh` になる (`gh config get git_protocol -h github.com`)。

## 参考

- [GitHub の SSH ホスト鍵の指紋](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)
- [GitHub Meta API](https://api.github.com/meta)
- [SSH 接続のテスト](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection)
