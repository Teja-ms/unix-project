#!/usr/bin/env bash
write_csv_report() {
  validate_inputs || return
  local output_dir="$1" stamp output total errors unique_clients failed_attempts suspicious
  stamp=$(date '+%Y%m%d-%H%M%S')
  output="$output_dir/log-analysis-$stamp.csv"
  mkdir -p -- "$output_dir" || { printf 'ERROR: cannot create report directory: %s\n' "$output_dir" >&2; return 1; }
  total=$(awk 'END { print NR+0 }' "$ACCESS_LOG")
  errors=$(awk '$9 ~ /^[45][0-9][0-9]$/ { n++ } END { print n+0 }' "$ACCESS_LOG")
  unique_clients=$(awk '{ print $1 }' "$ACCESS_LOG" | sort -u | wc -l | tr -d ' ')
  failed_attempts=$(grep -c 'Failed password' "$AUTH_LOG" || true)
  suspicious=$(grep -Eic "$SUSPICIOUS_HTTP_PATTERN" "$ACCESS_LOG" || true)
  {
    printf 'metric,value\n'
    printf 'http_requests,%s\nhttp_error_responses,%s\nunique_client_ips,%s\nssh_failed_attempts,%s\nsuspicious_http_requests,%s\n' "$total" "$errors" "$unique_clients" "$failed_attempts" "$suspicious"
  } > "$output" || { printf 'ERROR: failed to write report: %s\n' "$output" >&2; return 1; }
  printf 'CSV report written: %s\n' "$output"
}
