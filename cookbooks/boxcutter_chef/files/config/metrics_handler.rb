require 'chef/handler'
require 'time'

module Boxcutter
  class MetricsHandler < ::Chef::Handler
    def initialize(path: '/var/chef/reports', filename: 'chef-run-metrics.json')
      @path = path
      @filename = filename
    end

    def report
      # Will get called here on compile errors instead of exception
      Chef::Log.info('boxcutter_chef: metrics_hander - Entering report handler')
      write_metrics
    end

    def exception
      Chef::Log.info('boxcutter_chef: metrics_handler - Entering exception handler')
      write_metrics
    end

    private

    def metrics_path
      FileUtils.mkdir_p(@path)
      File.chmod(0o700, @path)
      File.join(@path, @filename)
    end

    def load_previous
      return {} unless File.exist?(metrics_path)
      JSON.parse(File.read(metrics_path))
    rescue JSON::ParserError, Errno::ENOENT
      {}
    end

    def write_metrics
      # Ruby to_s is close to ISO 8601, but not quite - use ISO 8601 instead.
      now = Time.now.iso8601

      prev = load_previous
      success = run_status.success?
      last_success = if success
                       now
                     else
                       prev['last_success_time_iso8601']
                     end

      out = {
        # stable schema keys (don't rename lightly)
        'report_time_iso8601' => now,
        'success' => success ? 1 : 0,
        'last_success_time_iso8601' => last_success,

        'start_time_iso8601' => run_status.start_time.iso8601,
        'end_time_iso8601' => run_status.end_time.iso8601,
        # run_status.elapsed time is start_time - end_time as a float in seconds
        # Convert to ms as integer (no way resolution is more granular than ms)
        'elapsed_time_ms' => run_status.elapsed_time * 1000,
        'all_resources_count' => run_status.all_resources.count,
        'updated_resources_count' => run_status.updated_resources.count,
      }

      File.open(metrics_path, 'w') { |f| f.write(JSON.pretty_generate(out)) }
      Chef::Log.info("wrote chef run metrics to #{metrics_path}")
    end
  end
end
