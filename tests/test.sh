#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
TMP="$(mktemp -d)"
cleanup() { rm -rf -- "$TMP"; }
trap cleanup EXIT
source "$ROOT/config/defaults.sh"
ACCESS_LOG="$ROOT/logs/access.log"
AUTH_LOG="$ROOT/logs/auth.log"
APP_LOG="$ROOT/logs/application.log"
REPORT_DIR="$TMP/reports"
source "$ROOT/modules/validation.sh"
source "$ROOT/modules/analytics.sh"
source "$ROOT/modules/security.sh"
source "$ROOT/modules/report.sh"
fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
assert_contains() { grep -Fq -- "$2" "$1" || fail "expected '$2' in $1"; }
require_commands
validate_inputs
http_overview > "$TMP/http.out"
assert_contains "$TMP/http.out" 'Requests:              9'
assert_contains "$TMP/http.out" 'Unique client IPs:     3'
ssh_failed_logins > "$TMP/ssh.out"
assert_contains "$TMP/ssh.out" '203.0.113.77'
suspicious_http_requests > "$TMP/suspicious.out"
assert_contains "$TMP/suspicious.out" '/.env'
write_csv_report "$REPORT_DIR" > "$TMP/report.out"
report="$(find "$REPORT_DIR" -name '*.csv' -type f | head -n 1)"
[[ -n "$report" ]] || fail 'CSV report was not created'
assert_contains "$report" 'http_requests,9'
assert_contains "$report" 'ssh_failed_attempts,4'
if validate_log_file "$TMP/missing.log" test > /dev/null 2>&1; then fail 'missing file was accepted'; fi
printf 'PASS: validation, HTTP analytics, SSH detection, suspicious paths, and CSV reporting.\n'
