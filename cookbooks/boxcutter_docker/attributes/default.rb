default['boxcutter_docker'] = {
  'enable' => true,
  'enable_cleanup' => true,
  'group' => 'docker',
  'config' => {
    'log-opts' => {
      'max-size' => '25m',
      'max-file' => '10',
    },
  },
  'buildx' => {},
  'containers' => {},
  'bind_mounts' => {},
  'volumes' => {},
  'networks' => {},
}
