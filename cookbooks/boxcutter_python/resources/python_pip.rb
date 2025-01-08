# Adapted the resource for `python-pip` in the archived git repository for
# https://github.com/DataDog/chef-python to current Chef custom resources
# format and python3.
#
# Original author: Seth Chisamore <schisamo@opscode.com>
#
provides :boxcutter_python_pip

property :package_name, String,
         description: 'The name of the Python package to install.',
         name_property: true
property :version, String,
         description: 'The version of the Python package to install/upgrade.'
property :pip_binary, String,
         description: 'Path to the pip binary. Mutually exclusive with `virtualenv`.',
         default: '/usr/bin/pip3'
property :virtualenv, String,
         description: 'Path to a virtual environment in which to install the Python package.'
property :user, [String, Integer],
         description: 'The user name or user ID used to run pip commands.',
         default: 'root'
property :group, [String, Integer],
         description: 'The group name or group ID used to pip commands.',
         default: 'root'
property :extra_options, String,
         description: 'Extra options to pass to the pip command.'
property :timeout, Integer,
         description: 'The number of seconds to wait for the pip command to complete.',
         default: 900
property :environment, Hash,
         description: 'Hash containing environment varibles to set before the pip command is run.',
         default: {}

load_current_value do |new_resource|
  package_name new_resource.package_name
  version nil
  unless Boxcutter::Python::Helpers.current_installed_version(new_resource).nil?
    version Boxcutter::Python::Helpers.current_installed_version(new_resource)
  end
end

action :install do
  # If we specified a version, and it's not the current version, move to the specified version
  if !new_resource.version.nil? && new_resource.version != current_resource.version
    install_version = new_resource.version
    # If it's not installed at all, install it
  elsif current_resource.version.nil?
    install_version = Boxcutter::Python::Helpers.candidate_version(new_resource)
  end

  if install_version
    description = "install package #{new_resource} version #{install_version}"
    converge_by(description) do
      Chef::Log.info("Installing #{new_resource} version #{install_version}")
      Boxcutter::Python::Helpers.install_package(install_version, new_resource)
    end
  end
end

action :upgrade do
  if current_resource.version != Boxcutter::Python::Helpers.candidate_version
    original_version = current_resource.version || 'uninstalled'
    description = "upgrade #{current_resource} version from #{current_resource.version} to #{candidate_version}"
    converge_by(description) do
      Chef::Log.info("Upgrading #{new_resource} version from #{original_version} to #{candidate_version}")
      Boxcutter::Python::Helpers.upgrade_package(candidate_version, new_resource)
    end
  end
end

action :remove do
  if removing_package?(current_resource, new_resource)
    description = "remove package #{new_resource}"
    converge_by(description) do
      Chef::Log.info("Removing #{new_resource}")
      Boxcutter::Python::Helpers.remove_package(new_resource.version, new_resource)
    end
  end
end
