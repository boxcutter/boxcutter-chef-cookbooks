#
# Cookbook:: boxcutter_github_test
# Recipe:: runner
#
include_recipe 'boxcutter_github::cli'

node.default['boxcutter_github']['github_runner'] = {
  'runners' => {
    '/home/github-runner/actions-runner' => {
      'runner_name' => node['hostname'],
      'url' => 'https://github.com/boxcutter/oci',
      'owner' => 'github-runner',
      'group' => 'github-runner',
    },
  },
}

include_recipe 'boxcutter_github::runner'
