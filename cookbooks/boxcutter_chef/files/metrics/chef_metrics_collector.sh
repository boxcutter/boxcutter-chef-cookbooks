#!/bin/bash
set -euo pipefail

# Adjust as needed.
CONFIG_FILE="/etc/boxcutter-config.json"
TEXTFILE_COLLECTOR_DIR=/var/lib/node_exporter/textfile/
INPUT_JSON='/var/chef/reports/chef-run-metrics.json'

# Convert ISO8601 → epoch seconds
iso_to_epoch() {
  local ts="$1"
  [[ -z "$ts" || "$ts" == "null" ]] && echo "0" && return

  # GNU date handles ISO 8601 natively
  date -d "$ts" +%s 2>/dev/null || echo "0"
}

metrics_to_stdout() {
  echo "Report time (ISO 8601): ${report_time_iso8601}"
  echo "Report time (Unix epoch): ${report_time_unix_epoch}"
  echo "Success: ${success}"
  echo "Last success time (ISO 8601): ${last_success_time_iso8601}"
  echo "Last success time (Unix epoch): ${last_success_unix_epoch}"
  echo "Start time (ISO 8601): ${start_time_iso8601}"
  echo "Start time (Unix epoch): ${start_time_unix_epoch}"
  echo "End time (ISO 8601): ${end_time_iso8601}"
  echo "End time (Unix epoch): ${end_time_unix_epoch}"
  echo "Elapsed time (ms): ${elapsed_time_ms}"
  echo "All resources: ${all_resources_count}"
  echo "Updated resources: ${updated_resources_count}"
  echo "Now (Unix epoch): ${now_unix_epoch}"
  echo "now - report_time (s): ${now_minus_report_time_seconds}"
  echo "now - last_success (s): ${now_minus_last_success_seconds}"
}

metrics_to_prometheus() {
  local tags="$1"

cat << EOF > "$TEXTFILE_COLLECTOR_DIR/chef_metrics.prom.$$"
# HELP chef_client_run_success Whether the last Chef run succeeded (1) or failed (0).
# TYPE chef_client_run_success gauge
chef_client_run_success${tags} ${success}
# HELP chef_client_run_last_success_timestamp_seconds Unix timestamp of the most recent successful Chef run.
# TYPE chef_client_run_last_success_timestamp_seconds gauge
chef_client_run_last_success_timestamp_seconds${tags} ${last_success_unix_epoch}
# HELP chef_client_run_last_timestamp_seconds Time in seconds since the last Chef run (might not have been successful).
# TYPE chef_client_run_last_timestamp_seconds gauge
chef_client_run_last_timestamp_seconds${tags} ${report_time_unix_epoch}
# HELP chef_client_run_duration_seconds Duration of the last Chef run in seconds.
# TYPE chef_client_run_duration_seconds gauge
chef_client_run_duration_seconds${tags} ${elapsed_seconds}
# HELP chef_client_run_resources_total Total resources in the last Chef run.
# TYPE chef_client_run_resources_total gauge
chef_client_run_resources_total${tags} ${all_resources_count}
# HELP chef_client_run_updated_resources_total Updated resources in the last Chef run.
# TYPE chef_client_run_updated_resources_total gauge
chef_client_run_updated_resources_total${tags} ${updated_resources_count}
# HELP chef_client_run_time_since_last_seconds Seconds since the last Chef run report time (now - report_time).
# TYPE chef_client_run_time_since_last_seconds gauge
chef_client_run_time_since_last_seconds${tags} ${now_minus_report_time_seconds}
# HELP chef_client_run_time_since_last_success_seconds Seconds since the last successful Chef run (now - last_success).
# TYPE chef_client_run_time_since_last_success_seconds gauge
chef_client_run_time_since_last_success_seconds${tags} ${now_minus_last_success_seconds}
EOF

  # Rename the temporary file atomically.
  # This avoids the node exporter seeing half a file.
  mv "$TEXTFILE_COLLECTOR_DIR/chef_metrics.prom.$$" \
    "$TEXTFILE_COLLECTOR_DIR/chef_metrics.prom"
}

# Extract fields (use //empty to avoid 'null' output and allow defaults)
report_time_iso8601="$(jq -r '.report_time_iso8601 // empty' "$INPUT_JSON")"
success="$(jq -r '.success // 0' "$INPUT_JSON")"
last_success_time_iso8601="$(jq -r '.last_success_time_iso8601 // empty' "$INPUT_JSON")"
start_time_iso8601="$(jq -r '.start_time_iso8601 // empty' "$INPUT_JSON")"
end_time_iso8601="$(jq -r '.end_time_iso8601 // empty' "$INPUT_JSON")"
elapsed_time_ms="$(jq -r '.elapsed_time_ms // empty' "$INPUT_JSON")"
all_resources_count="$(jq -r '.all_resources_count // empty' "$INPUT_JSON")"
updated_resources_count="$(jq -r '.updated_resources_count // empty' "$INPUT_JSON")"

report_time_unix_epoch=$(iso_to_epoch "${report_time_iso8601}")
last_success_unix_epoch="$(iso_to_epoch "${last_success_time_iso8601}")"
start_time_unix_epoch="$(iso_to_epoch "$start_time_iso8601")"
end_time_unix_epoch="$(iso_to_epoch "$end_time_iso8601")"

elapsed_seconds="$(jq -nr --arg v "$elapsed_time_ms" '($v|tonumber) / 1000.0')"

# "now" and convenience age metrics
now_unix_epoch="$(date +%s)"
now_minus_report_time_seconds="$(( now_unix_epoch - report_time_unix_epoch ))"
now_minus_last_success_seconds="$(( now_unix_epoch - last_success_unix_epoch ))"

# Guard against missing/zero timestamps producing huge/negative numbers
if [[ "$report_time_unix_epoch" -le 0 ]]; then
  now_minus_report_time_seconds="0"
fi
if [[ "$last_success_unix_epoch" -le 0 ]]; then
  now_minus_last_success_seconds="0"
fi
if [[ "$now_minus_report_time_seconds" -lt 0 ]]; then
  now_minus_report_time_seconds="0"
fi
if [[ "$now_minus_last_success_seconds" -lt 0 ]]; then
  now_minus_last_success_seconds="0"
fi

tier="default"
if [[ -r "$CONFIG_FILE" ]]; then
  t="$(jq -r '.tier // empty' "$CONFIG_FILE")"
  [[ -n "$t" ]] && tier="$t"
fi

tags="{tier=\"$tier\"}"
metrics_to_prometheus "$tags"
