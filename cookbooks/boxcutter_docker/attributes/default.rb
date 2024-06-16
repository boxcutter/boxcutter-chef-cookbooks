default['boxcutter_docker'] = {
  'enable' => true,
  'group' => 'docker',
  'config' => {
    'log-opts' => {
      'max-size' => '200m',
      'max-file' => '3',
    },
  },
  'context' => {},
}
