#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: node_exporter
#

# case node['kernel']['machine']
# when 'x86_64', 'amd64'
#   node.default['boxcutter_prometheus']['node_exporter']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz'
#   node.default['boxcutter_prometheus']['node_exporter']['checksum'] = \
#     'becb950ee80daa8ae7331d77966d94a611af79ad0d3307380907e0ec08f5b4e8'
#   node.default['boxcutter_prometheus']['node_exporter']['creates'] = \
#     'node_exporter-1.9.1.linux-amd64'
# when 'aarch64', 'arm64'
#   node.default['boxcutter_prometheus']['node_exporter']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-arm64.tar.gz'
#   node.default['boxcutter_prometheus']['node_exporter']['checksum'] = \
#     '848f139986f63232ced83babe3cad1679efdbb26c694737edc1f4fbd27b96203'
#   node.default['boxcutter_prometheus']['node_exporter']['creates'] = \
#     'node_exporter-1.9.1.linux-arm64'
# end

# https://grafana.com/oss/prometheus/exporters/node-exporter/
node.default['boxcutter_prometheus']['node_exporter']['command_line_flags'] = {
  'collector.systemd' => nil,
  'collector.processes' => nil,
  'no-collector.infiniband' => nil,
  'no-collector.nfs' => nil,
  'collector.textfile' => nil,
  'collector.textfile.directory' => '/var/lib/node_exporter/textfile',
  'web.listen-address' => ':9100',
}

include_recipe 'boxcutter_prometheus::node_exporter'

node.default['boxcutter_prometheus']['prometheus']['config'] = {
  'global' => {
    'scrape_interval' => '15s',
  },
  'scrape_configs' => [
    {
      'job_name' => 'node_exporter',
      'scrape_interval' => '5s',
      'static_configs' => [
        {
          'targets' => ['localhost:9100'],
        },
      ],
    },
  ],
}

node.default['boxcutter_prometheus']['prometheus']['recording_rules'] = {
  'groups' => [
    {
      'name' => 'node-exporter.rules',
      'rules' => [
        {
          'expr' => 'count without (cpu) (count without (mode)(node_cpu_seconds_total{job="node"}) )',
          'record' => 'instance:node_num_cpu:sum',
        },
        {
          'expr' => '1 - avg without (cpu, mode) (rate(node_cpu_seconds_total{job="node", mode="idle"}[1m]) )',
          'record' => 'instance:node_cpu_utilisation:rate1m',
        },
        {
          'expr' => '(node_load1{job="node"} / instance:node_num_cpu:sum{job="node"})',
          'record' => 'instance:node_load1_per_cpu:ratio',
        },
        {
          'expr' => '1 - (node_memory_MemAvailable_bytes{job="node"} / node_memory_MemTotal_bytes{job="node"})',
          'record' => 'instance:node_memory_utilisation:ratio',
        },
        {
          'expr' => 'rate(node_vmstat_pgmajfault{job="node"}[1m])',
          'record' => 'instance:node_vmstat_pgmajfault:rate1m',
        },
        {
          'expr' => 'rate(node_disk_io_time_seconds_total{job="node", device!=""}[1m])',
          'record' => 'instance_device:node_disk_io_time_seconds:rate1m',
        },
        {
          'expr' => 'rate(node_disk_io_time_weighted_seconds_total{job="node", device!=""}[1m])',
          'record' => 'instance_device:node_disk_io_time_weighted_seconds:rate1m',
        },
        {
          'expr' => 'sum without (device) (rate(node_network_receive_bytes_total{job="node", device!="lo"}[1m]))',
          'record' => 'instance:node_network_receive_bytes_excluding_lo:rate1m',
        },
        {
          'expr' => 'sum without (device) (rate(node_network_transmit_bytes_total{job="node", device!="lo"}[1m]))',
          'record' => 'instance:node_network_transmit_bytes_excluding_lo:rate1m',
        },
        {
          'expr' => 'sum without (device) (rate(node_network_receive_drop_total{job="node", device!="lo"}[1m]))',
          'record' => 'instance:node_network_receive_drop_excluding_lo:rate1m',
        },
        {
          'expr' => 'sum without (device) (rate(node_network_transmit_drop_total{job="node", device!="lo"}[1m]))',
          'record' => 'instance:node_network_transmit_drop_excluding_lo:rate1m',
        },
      ],
    },
  ],
}

node.default['boxcutter_prometheus']['prometheus']['alerting_rules'] = {
  'groups' => [
    {
      'name' => 'node-exporter',
      'rules' => [
        {
          'alert' => 'NodeFilesystemSpaceFillingUp',
          'annotations' => {
            'description' => 'Filesystem on {{ $labels.device }} at {{ $labels.instance }} has' \
                             ' only {{ printf "%.2f" $value }}% available space left and is filling up.',
            'summary' => 'Filesystem is predicted to run out of space within the next 24 hours.',
          },
          'expr' => '(node_filesystem_avail_bytes{job="node",fstype!=""}' \
                    ' / node_filesystem_size_bytes{job="node",fstype!=""} * 100 < 40' \
                    ' and predict_linear(node_filesystem_avail_bytes{job="node",fstype!=""}[6h], 24*60*60) < 0' \
                    ' and node_filesystem_readonly{job="node",fstype!=""} == 0)',
          'for' => '1h',
          'labels' => {
            'severity' => 'warning',
          },
        },
        {
          'alert' => 'NodeFilesystemSpaceFillingUp',
          'annotations' => {
            'description' => 'Filesystem on {{ $labels.device }} at {{ $labels.instance }} has' \
                             ' only {{ printf "%.2f" $value }}% available space left and is filling up fast.',
            'summary' => 'Filesystem is predicted to run out of space within the next 4 hours.',
          },
          'expr' => '(node_filesystem_avail_bytes{job="node",fstype!=""}' \
                    ' / node_filesystem_size_bytes{job="node",fstype!=""} * 100 < 20' \
                    ' and predict_linear(node_filesystem_avail_bytes{job="node",fstype!=""}[6h], 4*60*60) < 0' \
                    ' and node_filesystem_readonly{job="node",fstype!=""} == 0)',
          'for' => '1h',
          'labels' => {
            'severity' => 'critical',
          },
        },
        {
          'alert' => 'NodeFilesystemAlmostOutOfSpace',
          'annotations' => {
            'description' => 'Filesystem on {{ $labels.device }} at {{ $labels.instance }} has' \
                             ' only {{ printf "%.2f" $value }}% available space left.',
            'summary' => 'Filesystem has less than 5% space left.',
          },
          'expr' => '( node_filesystem_avail_bytes{job="node",fstype!=""}' \
                    ' / node_filesystem_size_bytes{job="node",fstype!=""} * 100 < 5' \
                    ' and node_filesystem_readonly{job="node",fstype!=""} == 0)',
          'for' => '1h',
          'labels' => {
            'severity' => 'warning',
          },
        },
        {
          'alert' => 'NodeFilesystemAlmostOutOfSpace',
          'annotations' => {
            'description' => 'Filesystem on {{ $labels.device }} at {{ $labels.instance }} has' \
                             ' only {{ printf "%.2f" $value }}% available space left.',
            'summary' => 'Filesystem has less than 3% space left.',
          },
          'expr' => '( node_filesystem_avail_bytes{job="node",fstype!=""}' \
                    ' / node_filesystem_size_bytes{job="node",fstype!=""} * 100 < 3' \
                    ' and node_filesystem_readonly{job="node",fstype!=""} == 0)',
          'for' => '1h',
          'labels' => {
            'severity' => 'critical',
          },
        },
        {
          'alert' => 'NodeFilesystemFilesFillingUp',
          'annotations' => {
            'description' => 'Filesystem on {{ $labels.device }} at {{ $labels.instance }} has' \
                             ' only {{ printf "%.2f" $value }}% available inodes left and is filling up.',
            'summary' => 'Filesystem is predicted to run out of inodes within the next 24 hours.',
          },
          'expr' => '( node_filesystem_files_free{job="node",fstype!=""}' \
                    ' / node_filesystem_files{job="node",fstype!=""} * 100 < 40' \
                    ' and predict_linear(node_filesystem_files_free{job="node",fstype!=""}[6h], 24*60*60) < 0'\
                    ' and node_filesystem_readonly{job="node",fstype!=""} == 0)',
          'for' => '1h',
          'labels' => {
            'severity' => 'warning',
          },
        },
        {
          'alert' => 'NodeFilesystemFilesFillingUp',
          'annotations' => {
            'description' => 'Filesystem on {{ $labels.device }} at {{ $labels.instance }} has' \
                             ' only {{ printf "%.2f" $value }}% available inodes left and is filling up fast.',
            'summary' => 'Filesystem is predicted to run out of inodes within the next 4 hours.',
          },
          'expr' => '( node_filesystem_files_free{job="node",fstype!=""}' \
                    ' / node_filesystem_files{job="node",fstype!=""} * 100 < 20' \
                    ' and predict_linear(node_filesystem_files_free{job="node",fstype!=""}[6h], 4*60*60) < 0' \
                    ' and node_filesystem_readonly{job="node",fstype!=""} == 0)',
          'for' => '1h',
          'labels' => {
            'severity' => 'critical',
          },
        },
        {
          'alert' => 'NodeFilesystemAlmostOutOfFiles',
          'annotations' => {
            'description' => 'Filesystem on {{ $labels.device }} at {{ $labels.instance }} has' \
                             ' only {{ printf "%.2f" $value }}% available inodes left.',
            'summary' => 'Filesystem has less than 5% inodes left.',
          },
          'expr' => '( node_filesystem_files_free{job="node",fstype!=""}' \
                    ' / node_filesystem_files{job="node",fstype!=""} * 100 < 5' \
                    ' and node_filesystem_readonly{job="node",fstype!=""} == 0)',
          'for' => '1h',
          'labels' => {
            'severity' => 'warning',
          },
        },
        {
          'alert' => 'NodeFilesystemAlmostOutOfFiles',
          'annotations' => {
            'description' => 'Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only'\
                             ' {{ printf "%.2f" $value }}% available inodes left.',
            'summary' => 'Filesystem has less than 3% inodes left.',
          },
          'expr' => '(node_filesystem_files_free{job="node",fstype!=""}' \
                    ' / node_filesystem_files{job="node",fstype!=""} * 100 < 3' \
                    ' and node_filesystem_readonly{job="node",fstype!=""} == 0)',
          'for' => '1h',
          'labels' => {
            'severity' => 'critical',
          },
        },
        {
          'alert' => 'NodeNetworkReceiveErrs',
          'annotations' => {
            'description' => '{{ $labels.instance }} interface {{ $labels.device }} has' \
                             ' encountered {{ printf "%.0f" $value }} receive errors in the last two minutes.',
            'summary' => 'Network interface is reporting many receive errors.',
          },
          'expr' => 'rate(node_network_receive_errs_total[2m]) / rate(node_network_receive_packets_total[2m]) > 0.01',
          'for' => '1h',
          'labels' => {
            'severity' => 'warning',
          },
        },
        {
          'alert' => 'NodeNetworkTransmitErrs',
          'annotations' => {
            'description' => '{{ $labels.instance }} interface {{ $labels.device }}' \
                             ' has encountered {{ printf "%.0f" $value }} transmit errors in the last two minutes.',
            'summary' => 'Network interface is reporting many transmit errors.',
          },
          'expr' => 'rate(node_network_transmit_errs_total[2m]) / rate(node_network_transmit_packets_total[2m]) > 0.01',
          'for' => '1h',
          'labels' => {
            'severity' => 'warning',
          },
        },
        {
          'alert' => 'NodeHighNumberConntrackEntriesUsed',
          'annotations' => {
            'description' => '{{ $value | humanizePercentage }} of conntrack entries are used.',
            'summary' => 'Number of conntrack are getting close to the limit.',
          },
          'expr' => '(node_nf_conntrack_entries / node_nf_conntrack_entries_limit) > 0.75',
          'labels' => {
            'severity' => 'warning',
          },
        },
        {
          'alert' => 'NodeTextFileCollectorScrapeError',
          'annotations' => {
            'description' => 'Node Exporter text file collector failed to scrape.',
            'summary' => 'Node Exporter text file collector failed to scrape.',
          },
          'expr' => 'node_textfile_scrape_error{job="node"} == 1',
          'labels' => {
            'severity' => 'warning',
          },
        },
        {
          'alert' => 'NodeClockSkewDetected',
          'annotations' => {
            'description' => 'Clock on {{ $labels.instance }} is out of sync by more than 300s.' \
                             ' Ensure NTP is configured correctly on this host.',
            'summary' => 'Clock skew detected.',
          },
          'expr' => '( node_timex_offset_seconds > 0.05 and deriv(node_timex_offset_seconds[5m]) >= 0)' \
                    ' or ( node_timex_offset_seconds < -0.05 and deriv(node_timex_offset_seconds[5m]) <= 0)',
          'for' => '10m',
          'labels' => {
            'severity' => 'warning',
          },
        },
        {
          'alert' => 'NodeClockNotSynchronising',
          'annotations' => {
            'description' => 'Clock on {{ $labels.instance }} is not synchronising. Ensure NTP is configured' \
                             ' on this host.',
            'summary' => 'Clock not synchronising.',
          },
          'expr' => 'min_over_time(node_timex_sync_status[5m]) == 0 and node_timex_maxerror_seconds >= 16',
          'for' => '10m',
          'labels' => {
            'severity' => 'warning',
          },
        },
        {
          'alert' => 'NodeRAIDDegraded',
          'annotations' => {
            'description' => "RAID array \'{{ $labels.device }}\' on {{ $labels.instance }} is in degraded state" \
                             ' due to one or more disks failures. Number of spare drives is insufficient to fix' \
                             ' issue automatically.',
            'summary' => 'RAID Array is degraded',
          },
          'expr' => 'node_md_disks_required - ignoring (state) (node_md_disks{state="active"}) > 0',
          'for' => '15m',
          'labels' => {
            'severity' => 'critical',
          },
        },
        {
          'alert' => 'NodeRAIDDiskFailure',
          'annotations' => {
            'description' => 'At least one device in RAID array on {{ $labels.instance }} failed.' \
                             " Array \'{{ $labels.device }}\' needs attention and possibly a disk swap.",
            'summary' => 'Failed device in RAID array',
          },
          'expr' => 'node_md_disks{state="failed"} > 0',
          'labels' => {
            'severity' => 'warning',
          },
        },
      ],
    },
  ],
}

node.default['boxcutter_prometheus']['prometheus']['command_line_flags'] = {
  'storage.tsdb.path' => '/var/lib/prometheus/data',
  'storage.tsdb.retention.time' => '30d',
  'storage.tsdb.retention.size' => '20GB',
  'web.listen-address' => '0.0.0.0:9090',
}

include_recipe 'boxcutter_prometheus::prometheus'

node.default['fb_grafana']['datasources']['prometheus'] = {
  'type' => 'prometheus',
  'orgId' => 1,
  'url' => 'http://localhost:9090',
  'access' => 'proxy',
  'isDefault' => true,
  'editable' => false,
}

node.default['fb_grafana']['config'] = {
  'auth.anonymous' => {
    'enabled' => true,
    'org_name' => 'Main Org.',
    'org_role' => 'Admin',
  },
  'auth.basic' => {
    'enabled' => false,
  },
  'auth' => {
    'disable_login_form' => true,
  },
  'paths' => {
    'data' => '/var/lib/grafana',
    'logs' => '/var/log/grafana',
    'plugins' => '/var/lib/grafana/plugins',
  },
  'server' => {
    'protocol' => 'http',
    'http_port' => 3000,
  },
}

include_recipe 'fb_grafana'

# https://grafana.com/grafana/dashboards/1860-node-exporter-full/
# https://grafana.com/api/dashboards/13978/revisions/1/download

# prometheus_ds = 'Prometheus'
#
# remote_file '/tmp/node_exporter_full_raw.json' do
#   source 'https://grafana.com/api/dashboards/1860/revisions/latest/download'
#   mode '0644'
# end
#
# ruby_block 'process node exporter dashboard JSON' do
#   block do
#     raw = File.read('/tmp/node_exporter_full_raw.json')
#     fixed = raw.gsub('${DS_PROMETHEUS}', prometheus_ds)
#     File.write('/tmp/node_exporter_full_clean.json', {
#       dashboard: JSON.parse(fixed),
#       overwrite: true
#     }.to_json)
#   end
# end
#
# http_request 'import node exporter dashboard' do
#   action :post
#   url 'http://localhost:3000/api/dashboards/db'
#   message lazy { File.read('/tmp/node_exporter_full_clean.json') }
#   headers({
#             'Content-Type' => 'application/json',
#             'Authorization' => 'Basic ' + Base64.strict_encode64('admin:admin')
#           })
# end
