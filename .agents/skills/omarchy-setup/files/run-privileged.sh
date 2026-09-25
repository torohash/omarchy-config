#!/bin/bash
# Collect the "特権で行う操作" blocks of the given skills into one script, run it in a single
# Omarchy floating terminal (the user types the sudo password once), and wait until it finishes.
#   run-privileged.sh [--print] <skill...>
# --print only shows the generated script. Run the real thing in the background: it blocks
# until the user finishes in the terminal.
source "$(dirname "$0")/lib.sh"

print_only=0
[ "${1:-}" = --print ] && { print_only=1; shift; }
[ $# -eq 0 ] && { echo "usage: $0 [--print] <skill...>" >&2; exit 2; }

run_dir="${XDG_RUNTIME_DIR:-/tmp}/omarchy-config"
script="$run_dir/privileged.sh"
result="$run_dir/privileged.result"
mkdir -p "$run_dir"; rm -f "$result"

{
  echo '#!/bin/bash'
  echo "result='$result'"
  echo 'echo "sudo のパスワードを 1 回だけ入力してください。"'
  echo 'sudo -v || { echo "FAILED sudo" > "$result"; exit 1; }'
  echo '# Keep the sudo timestamp alive until this script ends.'
  echo '( while kill -0 $$ 2>/dev/null; do sudo -n true; sleep 50; done ) &'
  echo 'status=0'
  for skill in "$@"; do
    code=$(section_code "$skill" "特権で行う操作")
    [ -z "$code" ] && continue
    echo
    echo "echo; echo \"==== $skill ====\""
    echo "( set -e"
    echo "$code"
    echo ")"
    echo "if [ \$? -ne 0 ]; then echo \"FAILED $skill\" >> \"\$result.tmp\"; status=1; fi"
  done
  echo
  echo '[ -f "$result.tmp" ] && mv "$result.tmp" "$result" || echo OK > "$result"'
  echo 'echo; echo "完了しました。このウィンドウは閉じて構いません。"'
  echo 'exit $status'
} > "$script"
chmod +x "$script"

if [ $print_only -eq 1 ]; then cat "$script"; exit 0; fi

omarchy-launch-floating-terminal-with-presentation "$script" >/dev/null 2>&1 &
until [ -f "$result" ]; do sleep 3; done
cat "$result"
[ "$(cat "$result")" = OK ]
