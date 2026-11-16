#!/usr/bin/env bash
require_commands() {
  local missing="" command_name
  for command_name in awk grep sed sort cut uniq date mktemp wc tr head tail mkdir; do
    command -v "$command_name" >/dev/null 2>&1 || missing="$missing $command_name"
  done
  if [[ -n "$missing" ]]; then
    printf 'Missing required commands:%s\n' "$missing" >&2
    return 1
  fi
}
validate_log_file() {
  local file="$1" label="$2"
  [[ -n "$label" ]] || label=log
  if [[ ! -e "$file" ]]; then printf 'ERROR: %s file does not exist: %s\n' "$label" "$file" >&2; return 1; fi
  if [[ ! -f "$file" || ! -r "$file" ]]; then printf 'ERROR: %s file is not a readable regular file: %s\n' "$label" "$file" >&2; return 1; fi
  if [[ ! -s "$file" ]]; then printf 'ERROR: %s file is empty: %s\n' "$label" "$file" >&2; return 1; fi
}
validate_inputs() {
  validate_log_file "$ACCESS_LOG" "HTTP access log" &&
    validate_log_file "$AUTH_LOG" "SSH authentication log" &&
    validate_log_file "$APP_LOG" "application log"
}
