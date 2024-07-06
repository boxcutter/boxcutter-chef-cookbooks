#
# Cookbook:: boxcutter_jfrog
# Recipe:: container_registry_docker
#
# Copyright:: 2024, Boxcutter
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

node.default['fb_iptables']['filter']['INPUT']['rules']['jcr'] = {
  'rules' => [
    '-p tcp --dport 8081 -j ACCEPT',
    '-p tcp --dport 8082 -j ACCEPT',
  ],
}

include_recipe 'boxcutter_docker'

node.default['boxcutter_docker']['volumes']['postgres_data'] = {}
node.default['boxcutter_docker']['volumes']['artifactory_data'] = {}
node.default['boxcutter_docker']['networks']['artifactory_network'] = {}

node.default['boxcutter_docker']['containers']['postgresql'] = {
  'image' => 'releases-docker.jfrog.io/postgres:15.6-alpine',
  'environment' => {
    'POSTGRES_DB' => 'artifactory',
    'POSTGRES_USER' => 'artifactory',
    'POSTGRES_PASSWORD' => 'superseekret',
  },
  'ports' => {
    '5432' => '5432',
  },
  'mounts' => {
    'postgres_data' => {
      'source' => 'postgres_data',
      'target' => '/var/lib/postgresql/data',
    },
    'localtime' => {
      'type' => 'bind',
      'source' => '/etc/localtime',
      'target' => '/etc/localtime:ro',
    },
  },
  'ulimits' => {
    'nproc' => '65535',
    'nofile' => '32000:40000',
  },
  'logging_options' => {
    'max-size' => '50m',
    'max-file' => '10',
  },
  'extra_options' => {
    'restart' => 'always',
    'log-driver' => 'json-file',
    'network' => 'artifactory_network',
  },
}

node.default['boxcutter_docker']['containers']['artifactory'] = {
  'image' => 'releases-docker.jfrog.io/jfrog/artifactory-jcr:latest',
  'environment' => {
    'ENABLE_MIGRATION' => 'y',
    'JF_SHARED_DATABASE_TYPE' => 'postgresql',
    'JF_SHARED_DATABASE_USERNAME' => 'artifactory',
    'JF_SHARED_DATABASE_PASSWORD' => 'superseekret',
    'JF_SHARED_DATABASE_URL' => 'jdbc:postgresql://postgresql:5432/artifactory',
    'JF_SHARED_DATABASE_DRIVER' => 'org.postgresql.Driver',
    'JF_SHARED_NODE_IP' => '10.63.45.247',
    # 'JF_SHARED_NODE_ID' => 'artifactory',
    # 'JF_SHARED_NODE_NAME' => 'artifactory',
    # 'JF_ROUTER_ENTRYPOINTS_EXTERNALPORT' => '8082',
  },
  'ports' => {
    '8081' => '8081',
    '8082' => '8082',
  },
  'mounts' => {
    'artifactory_data' => {
      'source' => 'artifactory_data',
      'target' => '/var/opt/jfrog/artifactory',
    },
    'localtime' => {
      'type' => 'bind',
      'source' => '/etc/localtime',
      'target' => '/etc/localtime:ro',
    },
  },
  'ulimits' => {
    'nproc' => '65535',
    'nofile' => '32000:40000',
  },
  'logging_options' => {
    'max-size' => '50m',
    'max-file' => '10',
  },
  'extra_options' => {
    'restart' => 'always',
    'log-driver' => 'json-file',
    'network' => 'artifactory_network',
  },
}
