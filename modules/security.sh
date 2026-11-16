#!/usr/bin/env bash
ssh_failed_logins() {
  validate_log_file "$AUTH_LOG" "SSH authentication log" || return
  printf '\nSSH failed-login sources (threshold: %s)\n' "$FAILED_LOGIN_THRESHOLD"
  awk '/Failed password/ { for (i=1; i<=NF; i++) if ($i == "from" && (i+1)<=NF) { print $(i+1); break } }' "$AUTH_LOG" |
    sort | uniq -c | sort -rn |
    awk -v threshold="$FAILED_LOGIN_THRESHOLD" '$1 >= threshold { printf "  ALERT: %-18s %s failed attempts\n", $2, $1; found=1 } END { if (!found) print "  No source reached the alert threshold." }'
}
ssh_successful_logins() {
  validate_log_file "$AUTH_LOG" "SSH authentication log" || return
  printf '\nSuccessful SSH logins\n'
  if ! grep -q 'Accepted password' "$AUTH_LOG"; then
    printf '  No successful SSH logins found.\n'
  else
    grep 'Accepted password' "$AUTH_LOG" |
      sed -nE 's/.*Accepted password for ([^ ]+) from ([^ ]+).*/  user=\1 source=\2/p'
  fi
}
suspicious_http_requests() {
  validate_log_file "$ACCESS_LOG" "HTTP access log" || return
  printf '\nSuspicious HTTP requests\n'
  if ! grep -Ein "$SUSPICIOUS_HTTP_PATTERN" "$ACCESS_LOG"; then printf '  No matching suspicious paths found.\n'; fi
}
security_review() { ssh_failed_logins; ssh_successful_logins; suspicious_http_requests; }
