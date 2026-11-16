#!/usr/bin/env bash
http_overview() {
  validate_log_file "$ACCESS_LOG" "HTTP access log" || return
  local total errors client_count
  total=$(awk 'END { print NR+0 }' "$ACCESS_LOG")
  errors=$(awk '$9 ~ /^[45][0-9][0-9]$/ { n++ } END { print n+0 }' "$ACCESS_LOG")
  client_count=$(awk '{ print $1 }' "$ACCESS_LOG" | sort -u | wc -l | tr -d ' ')
  printf '\nHTTP access overview\n  Requests:              %s\n  4xx/5xx responses:     %s\n  Unique client IPs:     %s\n' "$total" "$errors" "$client_count"
  printf '\nStatus code counts:\n'
  awk '$9 ~ /^[0-9][0-9][0-9]$/ { print $9 }' "$ACCESS_LOG" | sort | uniq -c | sort -rn |
    awk '{ printf "  %-8s %s\n", $2, $1 }'
}
top_clients() {
  validate_log_file "$ACCESS_LOG" "HTTP access log" || return
  printf '\nTop client IPs\n'
  cut -d ' ' -f 1 "$ACCESS_LOG" | sort | uniq -c | sort -rn | head -n 10 |
    awk '{ printf "  %-18s %s requests\n", $2, $1 }'
}
top_paths() {
  validate_log_file "$ACCESS_LOG" "HTTP access log" || return
  printf '\nTop requested paths\n'
  awk -F '"' 'NF > 1 { split($2, request, " "); if (request[2] != "") print request[2] }' "$ACCESS_LOG" |
    sort | uniq -c | sort -rn | head -n 10 |
    awk '{ printf "  %-28s %s requests\n", $2, $1 }'
}
http_analytics() { http_overview; top_clients; top_paths; }
