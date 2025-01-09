require 'chef/mixin/shell_out'

module Boxcutter
  class Python
    module Helpers
      include Chef::Mixin::ShellOut

      def read_pyvenv_cfg(pyvenv_cfg_path)
        config = {}
        ::File.foreach(pyvenv_cfg_path) do |line|
          # Skip comments or blank lines
          next if line.strip.empty? || line.strip.start_with?('#')

          # Split each line into key-value pairs
          key, value = line.strip.split('=', 2)
          config[key.strip] = value.strip if key && value
        end
        config
      end

      def remove_surrounding_single_quotes(string)
        if string.start_with?("'") && string.end_with?("'")
          string[1..-2]
        else
          string
        end
      end

      # these methods are the required overrides of
      # a provider that extends from Chef::Provider::Package
      # so refactoring into core Chef should be easy

      def current_installed_version(new_resource)
        @current_installed_version ||= begin
          # Normalize package name (e.g., replace underscores with hyphens)
          normalized_package_name = new_resource.package_name.gsub('_', '-')

          # Command to get package details using pip3 show
          version_check_cmd = "#{which_pip(new_resource)} show #{normalized_package_name}"

          # Run the command and capture the result
          result = shell_out(version_check_cmd)
          if result.exitstatus == 0
            # Extract the version from the 'Version:' line in `pip3 show` output
            result.stdout.match(/^Version:\s*(.+)$/i)[1]
          end
        end
      end

      def candidate_version(new_resource)
        @candidate_version ||= new_resource.version||'latest'
      end

      def install_package(version, new_resource)
        # if a version isn't specified (latest), is a source archive
        # (ex. http://my.package.repo/SomePackage-1.0.4.zip),
        # or from a VCS (ex. git+https://git.repo/some_pkg.git) then do not
        # append a version as this will break the source link
        if version == 'latest' || \
           new_resource.package_name.downcase.start_with?('http:', 'https:') || \
           ['git', 'hg', 'svn'].include?(new_resource.package_name.downcase.split('+')[0])
          version = ''
        else
          version = "==#{version}"
        end
        pip_cmd('install', version, new_resource)
      end

      def upgrade_package(version, new_resource)
        # Upgrades are just an install with the `--upgrade` parameter added
        new_resource.extra_options "#{new_resource.extra_options} --upgrade"
        install_package(version, new_resource)
      end

      def remove_package(_version, new_resource)
        new_resource.extra_options "#{new_resource.extra_options} --yes"
        # Python only allows one version to be installed at a time, so it's
        # not necessary to provide a version on uninstall.
        pip_cmd('uninstall', '', new_resource)
      end

      def removing_package?(current_resource, new_resource)
        if current_resource.version.nil?
          false # nothing to remove
        elsif new_resource.version.nil?
          true # remove any version of a package
        else
          new_resource.version == current_resource.version # we don't have the version we want to remove
        end
      end

      def pip_cmd(subcommand, version = '', new_resource)
        options = { :timeout => new_resource.timeout, :user => new_resource.user, :group => new_resource.group }
        environment = {}
        environment['HOME'] = Dir.home(new_resource.user) if new_resource.user
        environment.merge!(new_resource.environment) if new_resource.environment && !new_resource.environment.empty?
        options[:environment] = environment
        shell_out!(
          "#{which_pip(new_resource)} #{subcommand} #{new_resource.extra_options} " \
          "#{new_resource.package_name}#{version}", **options
)
      end

      def which_pip(new_resource)
        if new_resource.respond_to?('virtualenv') && new_resource.virtualenv
          ::File.join(new_resource.virtualenv, '/bin/pip')
        else
          new_resource.pip_binary
        end
      end
    end
  end
end
