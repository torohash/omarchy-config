#!/bin/bash
# Run each skill's "確認" block and print ok / NG. Usage: status.sh [skill...]
# With no arguments, checks every skill in order.txt. Exit status is 1 if any is NG.
source "$(dirname "$0")/lib.sh"

skills=("$@")
[ ${#skills[@]} -eq 0 ] && mapfile -t skills < <(ordered_skills)

failed=0
for skill in "${skills[@]}"; do
  code=$(section_code "$skill" "確認")
  if [ -z "$code" ]; then
    printf '%-20s ?? (確認の節が無い)\n' "$skill"; failed=1; continue
  fi
  if bash -c "$code" >/dev/null 2>&1; then
    printf '%-20s ok\n' "$skill"
  else
    printf '%-20s NG\n' "$skill"; failed=1
  fi
done
exit $failed
