default['boxcutter_docker'] = {
  'enable' => true,
  'group' => 'docker',
  'config' => {
    'log-opts' => {
      'max-size' => '25m',
      'max-file' => '10',
    },
  },
  'buildx' => {},
  'contexts' => {},
  'containers' => {},
  'bind_mounts' => {},
  'volumes' => {},
  'devices' => {},
  'networks' => {},
}
