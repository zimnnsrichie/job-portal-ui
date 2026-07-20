#!/usr/bin/env bash
# Claude Code status line: model name + context usage progress bar
# Lives inside the job-portal-ui project (.claude/statusline.sh) so it can be
# version-controlled and edited alongside the rest of the project tooling.

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# ANSI colors, dimmed (\033[2;...) to match the terminal's dimmed color scheme
CYAN='\033[2;36m'
GREEN='\033[2;32m'
YELLOW='\033[2;33m'
RED='\033[2;31m'
GREY='\033[2;37m'
RESET='\033[0m'

printf "${CYAN}%s${RESET}" "$model"

if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  [ "$used_int" -lt 0 ] && used_int=0
  [ "$used_int" -gt 100 ] && used_int=100

  bar_width=10
  filled=$(( used_int * bar_width / 100 ))
  empty=$(( bar_width - filled ))

  if [ "$used_int" -ge 80 ]; then
    color="$RED"
  elif [ "$used_int" -ge 50 ]; then
    color="$YELLOW"
  else
    color="$GREEN"
  fi

  bar=""
  i=0
  while [ "$i" -lt "$filled" ]; do bar="${bar}█"; i=$((i + 1)); done
  i=0
  while [ "$i" -lt "$empty" ]; do bar="${bar}░"; i=$((i + 1)); done

  printf " ${GREY}[${color}%s${GREY}]${RESET} ${color}%d%%${RESET}" "$bar" "$used_int"
else
  printf " ${GREY}[no context data]${RESET}"
fi

printf '\n'
