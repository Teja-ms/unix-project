# UNIX Log File Analyzer

A modular, menu-driven log analyzer written in Bash for Ubuntu/Linux. It reads sample Apache-style HTTP access, SSH authentication, and application logs. Analysis uses standard UNIX tools such as grep, awk, sed, sort, cut, and uniq. No Python or third-party packages are used.

## Project layout

    unix-log-analyzer/
    ├── analyzer.sh
    ├── config/defaults.sh
    ├── modules/ (validation, analytics, security, report)
    ├── logs/ (synthetic demonstration data)
    ├── reports/ (generated CSV reports)
    └── tests/test.sh

## Ubuntu setup

Open Terminal and install Bash plus the standard tools if needed:

    sudo apt update
    sudo apt install -y bash coreutils grep gawk sed unzip

Extract the downloaded ZIP, then enter its directory. If the ZIP is in Downloads:

    cd ~/Downloads
    unzip unix-log-analyzer.zip
    cd unix-log-analyzer

Make the scripts executable:

    chmod +x analyzer.sh tests/test.sh

## Run the analyzer

Start the interactive menu:

    ./analyzer.sh

Menu options:

1. HTTP request, response-code, client, and path summaries.
2. SSH failed-login threshold alerts, successful logins, and suspicious HTTP paths.
3. Write a timestamped CSV report into reports/.
4. Check required commands and all three input logs.
5. Summarize application log levels and show recent errors.
0. Exit.

Run a feature directly:

    ./analyzer.sh --validate
    ./analyzer.sh --http
    ./analyzer.sh --security
    ./analyzer.sh --report

The bundled records are synthetic and use documentation-only IP address ranges. Replace files under logs/ with copies of logs you are authorized to analyze. Keep each input in the matching format: Apache/Nginx combined access log, Ubuntu auth.log SSH messages, and plain text application messages.

## What to expect

With the included sample data, HTTP analytics reports 9 requests, 5 error or client-error responses, and 3 unique client IPs. The security review flags 203.0.113.77 after three SSH failures and lists requests for /admin, /.env, and /wp-admin. The CSV contains one metric/value row per summary statistic.

## How the UNIX tools work here

- grep searches lines for patterns, such as failed SSH passwords or risky URL paths.
- awk reads whitespace-separated fields. In the HTTP log, field 1 is the client IP and field 9 is the HTTP status code.
- sed applies a regular expression to pull the SSH username and source IP from a successful-login message.
- cut selects the first space-separated field to extract client IPs.
- sort puts matching values together; uniq -c counts each run of identical values; sort -rn ranks those counts from largest to smallest.
- Bash connects these tools with pipes (|), stores reusable steps in functions, and uses the menu to choose which analysis runs.

## Run tests

From the project directory:

    bash tests/test.sh

Expected result:

    PASS: validation, HTTP analytics, SSH detection, suspicious paths, and CSV reporting.

## UNIX commands demonstrated

- grep finds SSH failures, successful logins, and suspicious URL patterns.
- awk parses status codes, methods, paths, and log levels and computes counts.
- sed extracts usernames and source addresses from successful SSH messages.
- cut extracts HTTP client addresses.
- sort and uniq -c group repeated values; sort -rn ranks the counts.
- Bash functions, case, loops, source, traps, pipes, and exit statuses tie modules together.

## Notes

The brute-force alert triggers when one source address has at least three failed SSH attempts. Edit FAILED_LOGIN_THRESHOLD in config/defaults.sh to change it. These rules are demonstrative heuristics: inspect alerts in context and do not treat a match as proof of an attack.
