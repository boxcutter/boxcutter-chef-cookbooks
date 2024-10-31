#
# Cookbook:: boxcutter_docker_test
# Recipe:: default
#
include_recipe 'boxcutter_docker::default'

docker_user = 'boxcutter'
docker_group = 'boxcutter'
docker_home = '/home/boxcutter'

FB::Users.initialize_group(node, docker_user)
node.default['fb_users']['users'][docker_user] = {
  'home' => docker_home,
  'shell' => '/bin/bash',
  'gid' => docker_group,
  'action' => :add,
}

node.default['fb_users']['groups']['docker']['members'] << 'boxcutter'
node.default['fb_users']['groups']['docker']['members'] << 'taylor'

node.default['boxcutter_docker']['volumes']['prometheus_data'] = {}

node.default['boxcutter_docker']['volumes']['postgres_data'] = {
  'Name' => 'postgres-data',
}

node.default['boxcutter_docker']['networks']['monitoring_network'] = {}

node.default['boxcutter_docker']['containers']['nginx'] = {
  'image' => 'docker.io/nginx',
  'ports' => {
    '8080' => '80',
  },
}
