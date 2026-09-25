# Shared helpers for omarchy-setup scripts (sourced, not executed).
SKILLS_DIR="${SKILLS_DIR:-$HOME/dev/config/.agents/skills}"

# Print the bash code blocks inside the "## <heading>" section of a skill's SKILL.md.
section_code() {
  local skill=$1 heading=$2
  # Code blocks may be indented inside numbered lists; strip that indentation.
  awk -v h="## $heading" '
    index($0, h) == 1 { in_sec = 1; next }
    in_sec && /^## / { exit }
    in_sec && !in_code && /^ *```bash$/ { in_code = 1; match($0, /^ */); indent = RLENGTH; next }
    in_sec && in_code && /^ *```$/ { in_code = 0; next }
    in_sec && in_code { print substr($0, indent + 1) }
  ' "$SKILLS_DIR/$skill/SKILL.md"
}

# Skill names from order.txt (optionally only "必須" or "任意").
ordered_skills() {
  grep -v -e '^#' -e '^$' "$SKILLS_DIR/omarchy-setup/files/order.txt" \
    | awk -v want="${1:-}" 'want == "" || $2 == want { print $1 }'
}
