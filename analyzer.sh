#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
REPORT_DIR="$SCRIPT_DIR/reports"
ACCESS_LOG="$LOG_DIR/access.log"
AUTH_LOG="$LOG_DIR/auth.log"
APP_LOG="$LOG_DIR/application.log"
source "$SCRIPT_DIR/config/defaults.sh"
source "$SCRIPT_DIR/modules/validation.sh"
source "$SCRIPT_DIR/modules/analytics.sh"
source "$SCRIPT_DIR/modules/security.sh"
source "$SCRIPT_DIR/modules/report.sh"
on_error() { local code="$?" line="$1"; printf 'ERROR: command failed near line %s (exit %s).\n' "$line" "$code" >&2; exit "$code"; }
trap 'on_error "$LINENO"' ERR
usage() {
  cat <<'USAGE'
Usage: ./analyzer.sh [--help|--validate|--http|--security|--report]
With no option, opens the interactive menu.
USAGE
}
show_menu() {
  printf '\n%s\n' "$PROJECT_NAME"
  printf '%s\n' '1) HTTP analytics' '2) SSH and HTTP security review' '3) Generate CSV report' '4) Validate inputs and dependencies' '5) Application log summary' '0) Exit'
}
application_summary() {
  validate_log_file "$APP_LOG" "application log" || return
  printf '\nApplication log levels\n'
  awk '{ for (i=1; i<=NF; i++) if ($i ~ /^(INFO|WARN|ERROR|DEBUG)$/) { print $i; break } }' "$APP_LOG" |
    sort | uniq -c | sort -rn | awk '{ printf "  %-8s %s entries\n", $2, $1 }'
  printf '\nRecent application errors:\n'
  grep -i 'ERROR' "$APP_LOG" | tail -n 5 || printf '  No errors found.\n'
}
while (($#)); do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --validate) require_commands; validate_inputs; printf 'Validation passed: dependencies and all sample logs are ready.\n'; exit 0 ;;
    --http) http_analytics; exit 0 ;;
    --security) security_review; exit 0 ;;
    --report) write_csv_report "$REPORT_DIR"; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done
require_commands
validate_inputs
while true; do
  show_menu
  read -r -p 'Select an option: ' choice || { printf '\n'; break; }
  case "$choice" in
    1) http_analytics ;;
    2) security_review ;;
    3) write_csv_report "$REPORT_DIR" ;;
    4) require_commands && validate_inputs && printf 'Validation passed.\n' ;;
    5) application_summary ;;
    0) printf 'Goodbye.\n'; break ;;
    *) printf 'Invalid choice. Enter 0 through 5.\n' ;;
  esac
done
