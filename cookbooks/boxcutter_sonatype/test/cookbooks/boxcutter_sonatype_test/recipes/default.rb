#
# Cookbook:: boxcutter_sonatype_test
# Recipe:: default
#
node.run_state['boxcutter_sonatype'] ||= {}
node.run_state['boxcutter_sonatype']['nexus_repository'] ||= {}
node.run_state['boxcutter_sonatype']['nexus_repository']['admin_username'] = 'admin'
node.run_state['boxcutter_sonatype']['nexus_repository']['admin_password'] = 'Superseekret63'

node.default['boxcutter_sonatype']['nexus_repository']['roles'] = {
  'engineering-read-only' => {
    'id' => 'engineering-read-only',
    'name' => 'engineering-read-only',
    'description' => 'Read-only access to engineering repositories',
    'privileges' => [
      'nx-healthcheck-read',
      'nx-search-read',
      'nx-repository-view-*-*-read',
      'nx-repository-view-*-*-browse',
    ],
    'roles' => [],
  },
}
node.default['boxcutter_sonatype']['nexus_repository']['users'] = {
  'chef' => {
    'user_id' => 'chef',
    'first_name' => 'Chef',
    'last_name' => 'User',
    'email_address' => 'nobody@nowhere.com',
    'password' => 'superseekret',
    'roles' => ['nx-admin'],
  },
}

node.default['boxcutter_sonatype']['nexus_repository']['blobstores'] = {
  'default' => {
    'name' => 'default',
    'type' => 'file',
    'path' => 'default',
  },
}

node.default['boxcutter_sonatype']['nexus_repository']['repositories'] = {
  'testy-hosted' => {
    'name' => 'testy-hosted',
    'type' => 'hosted',
    'format' => 'raw',
  },
  'gazebo-apt-proxy' => {
    'name' => 'gazebo-apt-proxy',
    'type' => 'proxy',
    'format' => 'apt',
    'proxy_remote_url' => 'http://packages.osrfoundation.org/gazebo/ubuntu-stable',
    'apt_distribution' => 'jammy',
    'apt_flat' => false,
  },
  'ros-proxy' => {
    'name' => 'ros-proxy',
    'type' => 'proxy',
    'format' => 'apt',
    'proxy_remote_url' => 'http://packages.ros.org/ros2/ubuntu',
    'apt_distribution' => 'jammy',
    'apt_flat' => false,
  },
  'ubuntu-archive-proxy' => {
    'name' => 'ubuntu-archive-proxy',
    'type' => 'proxy',
    'format' => 'apt',
    'proxy_remote_url' => 'http://archive.ubuntu.com/ubuntu/',
    'apt_distribution' => 'jammy',
    'apt_flat' => false,
  },
  'ubuntu-security-proxy' => {
    'name' => 'ubuntu-security-proxy',
    'type' => 'proxy',
    'format' => 'apt',
    'proxy_remote_url' => 'http://security.ubuntu.com/ubuntu/',
    'apt_distribution' => 'jammy',
    'apt_flat' => false,
  },
  'ubuntu-ports-proxy' => {
    'name' => 'ubuntu-ports-proxy',
    'type' => 'proxy',
    'format' => 'apt',
    'proxy_remote_url' => 'http://ports.ubuntu.com/ubuntu-ports',
    'apt_distribution' => 'jammy',
    'apt_flat' => false,
  },
  'ubuntu-releases-proxy' => {
    'name' => 'ubuntu-releases-proxy',
    'type' => 'proxy',
    'format' => 'raw',
    'proxy_remote_url' => 'https://releases.ubuntu.com',
  },
  'ubuntu-cdimage-proxy' => {
    'name' => 'ubuntu-cdimage-proxy',
    'type' => 'proxy',
    'format' => 'raw',
    'proxy_remote_url' => 'https://cdimage.ubuntu.com',
  },
  'ubuntu-cloud-images-proxy' => {
    'name' => 'ubuntu-cloud-images-proxy',
    'type' => 'proxy',
    'format' => 'raw',
    'proxy_remote_url' => 'https://cloud-images.ubuntu.com',
  },
  'cinc-proxy' => {
    'name' => 'cinc-proxy',
    'type' => 'proxy',
    'format' => 'raw',
    'proxy_remote_url' => 'https://ftp.osuosl.org/pub/cinc',
    'online' => false,
  },
  'cinc-omnitruck-proxy' => {
    'name' => 'cinc-omnitruck-proxy',
    'type' => 'proxy',
    'format' => 'raw',
    'proxy_remote_url' => 'https://omnitruck.cinc.sh',
  },
  'onepassword-proxy' => {
    'name' => 'onepassword-proxy',
    'type' => 'proxy',
    'format' => 'raw',
    'proxy_remote_url' => 'https://cache.agilebits.com',
  },
  'docker-proxy' => {
    'name' => 'docker-proxy',
    'type' => 'proxy',
    'format' => 'docker',
    'proxy_remote_url' => 'https://registry-1.docker.io',
    'docker_v1_enabled' => true,
    'docker_force_basic_auth' => true,
    'docker_http_port' => 10080,
    'docker_https_port' => 10443,
    'docker_proxy_index_type' => 'HUB',
  },
  'npm-proxy' => {
    'name' => 'npm-proxy',
    'type' => 'proxy',
    'format' => 'npm',
    'proxy_remote_url' => 'https://registry.npmjs.org',
  },
  'npm-hosted' => {
    'name' => 'npm-hosted',
    'type' => 'hosted',
    'format' => 'npm',
  },
  'pypi-proxy' => {
    'name' => 'python-proxy',
    'type' => 'proxy',
    'format' => 'pypi',
    'proxy_remote_url' => 'https://pypi.org/',
  },
  'pypi-hosted' => {
    'name' => 'python-hosted',
    'type' => 'hosted',
    'format' => 'pypi',
  },
}

include_recipe 'boxcutter_sonatype::default'
