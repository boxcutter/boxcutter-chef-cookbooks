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
# HELP chef_client_run_duration_seconds Duration of the last Chef run in seconds.
# TYPE chef_client_run_duration_seconds gauge
chef_client_run_duration_seconds${tags} ${elapsed_seconds}
# HELP chef_client_run_resources_total Total resources in the last Chef run.
# TYPE chef_client_run_resources_total gauge
chef_client_resources_total${tags} ${all_resources_count}
# HELP chef_client_run_updated_resources_total Updated resources in the last Chef run.
# TYPE chef_client_run_updated_resources_total gauge
chef_client_updated_resources_total${tags} ${updated_resources_count}
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

if [[ -r "$CONFIG_FILE" ]]; then
  tier="$(jq -r '.tier // empty' "$CONFIG_FILE")"
  [[ -n "$tier" ]] || tier="default"
fi

tags="{tier=\"$tier\"}"
metrics_to_prometheus "$tags"
