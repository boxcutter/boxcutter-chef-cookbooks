default['boxcutter_fluent']['fluentd'] = {
  'enable' => true,
  'config' => {
    'system' => {
      'log_level' => 'info',
    },
    'config' => [
      {
        ## built-in TCP input
        ## @see http://docs.fluentd.org/articles/in_forward
        'source' => {
          '$type' => 'http',
          '$id' => 'input_forward',
        },
      },
      {
        # HTTP input
        # POST http://localhost:8888/<tag>?json=<json>
        # POST http://localhost:8888/td.myapp.login?json={"user"%3A"me"}
        # @see http://docs.fluentd.org/articles/in_http
        'source' => {
          '$type' => 'http',
          '$id' => 'input_http',
          'port' => '8888',
        },
      },
      {
        ## live debugging agent
        'source' => {
          '$type' => 'debug_agent',
          '$id' => 'input_debug_agent',
          'bind' => '127.0.0.1',
          'port' => '24230',
        },
      },
    ],
  },
}

default['boxcutter_fluent']['fluent_bit'] = {
  'enable' => true,
  'config' => {
    # https://github.com/fluent/fluent-bit/blob/master/conf/parsers.conf
    'parsers' => [
      {
        'name' => 'apache',
        'format' => 'regex',
        'regex' => '^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] ' +
                   '"(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ' +
                   ']*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$',
        'time_key' => 'time',
        'time_format' => '%d/%b/%Y:%H:%M:%S %z',
      },
      {
        'name' => 'apache2',
        'format' => 'regex',
        'regex' => '^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] ' +
                   '"(?<method>\S+)(?: +(?<path>[^ ]*) +\S*)?" (?<code>[^ ]*) ' +
                   '(?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>.*)")?$',
        'time_key' => 'time',
        'time_format' => '%d/%b/%Y:%H:%M:%S %z',
      },
      {
        'name' => 'apache_error',
        'format' => 'regex',
        'regex' => '^\[[^ ]* (?<time>[^\]]*)\] \[(?<level>[^\]]*)\](?: ' +
                   '\[pid (?<pid>[^\]]*)\])?( \[client (?<client>[^\]]*)\])? (?<message>.*)$',
      },
      {
        'name' => 'nginx',
        'format' => 'regex',
        'regex' => '^(?<remote>[^ ]*) (?<host>[^ ]*) (?<user>[^ ]*) ' +
                   '\[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: ' +
                   '+\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" ' +
                   '"(?<agent>[^\"]*)")',
        'time_key' => 'time',
        'time_format' => '%d/%b/%Y:%H:%M:%S %z',
      },
      {
        # https://rubular.com/r/IhIbCAIs7ImOkc
        'name' => 'k8s-nginx-ingress',
        'format' => 'regex',
        'regex' => '^(?<host>[^ ]*) - (?<user>[^ ]*) \[(?<time>[^\]]*)\] ' +
                   '"(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ' +
                   ']*) (?<size>[^ ]*) "(?<referer>[^\"]*)" "(?<agent>[^\"]*)" ' +
                   '(?<request_length>[^ ]*) (?<request_time>[^ ]*) ' +
                   '\[(?<proxy_upstream_name>[^ ]*)\] (\[(?<proxy_alternative_upstream_name>[^ ' +
                   ']*)\] )?(?<upstream_addr>[^ ]*) (?<upstream_response_length>[^ ]*) ' +
                   '(?<upstream_response_time>[^ ]*) (?<upstream_status>[^ ]*) (?<reg_id>[^ ]*).*$',
        'time_key' => 'time',
        'time_format' => '%d/%b/%Y:%H:%M:%S %z',
      },
      {
        'name' => 'json',
        'format' => 'json',
        'time_key' => 'time',
        'time_format'=> '%d/%b/%Y:%H:%M:%S %z',
      },
      {
        'name' => 'logfmt',
        'format' => 'logfmt',
      },
      {
        'name' => 'docker',
        'format' => 'json',
        'time_key' => 'time',
        'time_format' => '%Y-%m-%dT%H:%M:%S.%L',
        'time_keep' => 'on',
        # --
        # Since Fluent Bit v1.2, if you are parsing Docker logs and using
        # the Kubernetes filter, it's not longer required to decode the
        # 'log' key.
        #
        # Command      |  Decoder | Field | Optional Action
        # =============|==================|=================
        # Decode_Field_As    json     log
      },
      {
        'name' => 'docker-daemon',
        'format' => 'regex',
        'regex' => 'time="(?<time>[^ ]*)" level=(?<level>[^ ]*) msg="(?<msg>[^ ].*)"',
        'time_key' => 'time',
        'time_format' => '%Y-%m-%dT%H:%M:%S.%L',
        'time_keep' => 'on',
      },
      {
        'name' => 'syslog-rfc5424',
        'format' => 'regex',
        'regex' => '^\<(?<pri>[0-9]{1,5})\>1 (?<time>[^ ]+) (?<host>[^ ]+) (?<ident>[^ ' +
                   ']+) (?<pid>[-0-9]+) (?<msgid>[^ ]+) (?<extradata>(\[(.*?)\]|-)) ' +
                   '(?<message>.+)$',
        'time_key' => 'time',
        'time_format' => '%Y-%m-%dT%H:%M:%S.%L%z',
        'time_keep' => 'on',
      },
      {
        'name' => 'syslog-rfc3164-local',
        'format' => 'regex',
        'regex' => '^\<(?<pri>[0-9]+)\>(?<time>[^ ]* {1,2}[^ ]* [^ ]*) ' +
                   '(?<ident>[a-zA-Z0-9_\/\.\-]*)(?:\[(?<pid>[0-9]+)\])?(?:[^\:]*\:)? ' +
                   '*(?<message>.*)$',
        'time_key' => 'time',
        'time_format' => '%b %d %H:%M:%S',
        'time_keep' => 'on',
      },
      {
        'name' => 'syslog-rfc3164',
        'format' => 'regex',
        'regex' => '/^\<(?<pri>[0-9]+)\>(?<time>[^ ]* {1,2}[^ ]* [^ ]*) (?<host>[^ ]*) ' +
                   '(?<ident>[a-zA-Z0-9_\/\.\-]*)(?:\[(?<pid>[0-9]+)\])?(?:[^\:]*\:)? ' +
                   '*(?<message>.*)$/',
        'time_key' => 'time',
        'time_format' => '%b %d %H:%M:%S',
        'time_keep' => 'on',
      },
      {
        'name' => 'mongodb',
        'format' => 'regex',
        'regex' => '^(?<time>[^ ]*)\s+(?<severity>\w)\s+(?<component>[^ ' +
                   ']+)\s+\[(?<context>[^\]]+)]\s+(?<message>.*?) *(?<ms>(\d+))?(:?ms)?$',
        'time_format' => '%Y-%m-%dT%H:%M:%S.%L',
        'time_keep' => 'on',
        'time_key' => 'time',
      },
      {
        # https://rubular.com/r/0VZmcYcLWMGAp1
        'name' => 'envoy',
        'format' => 'regex',
        'regex' => '^\[(?<start_time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: ' +
                   '+\S*)?)? (?<protocol>\S+)" (?<code>[^ ]*) (?<response_flags>[^ ]*) ' +
                   '(?<bytes_received>[^ ]*) (?<bytes_sent>[^ ]*) (?<duration>[^ ]*) ' +
                   '(?<x_envoy_upstream_service_time>[^ ]*) "(?<x_forwarded_for>[^ ]*)" ' +
                   '"(?<user_agent>[^\"]*)" "(?<request_id>[^\"]*)" "(?<authority>[^ ]*)" ' +
                   '"(?<upstream_host>[^ ]*)"',
        'time_format' => '%Y-%m-%dT%H:%M:%S.%L%z',
        'time_keep' => 'on',
        'time_key' => 'start_time',
      },
      {
        # https://rubular.com/r/17KGEdDClwiuDG
        'name' => 'istio-envoy-proxy',
        'format' => 'regex',
        'regex' => '^\[(?<start_time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: ' +
                   '+\S*)?)? (?<protocol>\S+)" (?<response_code>[^ ]*) ' +
                   '(?<response_flags>[^ ]*) (?<response_code_details>[^ ]*) ' +
                   '(?<connection_termination_details>[^ ]*) ' +
                   '(?<upstream_transport_failure_reason>[^ ]*) (?<bytes_received>[^ ]*) ' +
                   '(?<bytes_sent>[^ ]*) (?<duration>[^ ]*) ' +
                   '(?<x_envoy_upstream_service_time>[^ ]*) "(?<x_forwarded_for>[^ ]*)" ' +
                   '"(?<user_agent>[^\"]*)" "(?<x_request_id>[^\"]*)" (?<authority>[^ ]*)" ' +
                   '"(?<upstream_host>[^ ]*)" (?<upstream_cluster>[^ ]*) ' +
                   '(?<upstream_local_address>[^ ]*) (?<downstream_local_address>[^ ]*) ' +
                   '(?<downstream_remote_address>[^ ]*) (?<requested_server_name>[^ ]*) ' +
                   '(?<route_name>[^  ]*)',
        'time_format' => '%Y-%m-%dT%H:%M:%S.%L%z',
        'time_keep' => 'on',
        'time_key' => 'start_time',
      },
      {
        # http://rubular.com/r/tjUt3Awgg4
        'name' => 'cri',
        'format' => 'regex',
        'regex' => '^(?<time>[^ ]+) (?<stream>stdout|stderr) (?<logtag>[^ ]*) (?<message>.*)$',
        'time_key' => 'time',
        'time_format' => '%Y-%m-%dT%H:%M:%S.%L%z',
        'time_keep' => 'on',
      },
      {
        'name' => 'kube-custom',
        'format' => 'regex',
        'regex' => '(?<tag>[^.]+)?\.?(?<pod_name>[a-z0-9](?:[-a-z0-9]*[a-z0-9])' +
                   '?(?:\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_' +
                   '(?<container_name>.+)-(?<docker_id>[a-z0-9]{64})\.log$',
      },
      {
        # Examples: TCP: https://rubular.com/r/Q8YY6fHqlqwGI0
        #           UDP: https://rubular.com/r/B0ID69H9FvN0tp
        'name' => 'kmsg-netfilter-log',
        'format' => 'regex',
        'regex' => '^\<(?<pri>[0-9]{1,5})\>1 (?<time>[^ ]+) (?<host>[^ ]+) kernel - - - ' +
                   '\[[0-9\.]*\] (?<logprefix>[^ ]*)\s?IN=(?<in>[^ ]*) OUT=(?<out>[^ ]*) ' +
                   'MAC=(?<macsrc>[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}' +
                   ':[0-9a-f]{2}):(?<macdst>[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}' +
                   ':[0-9a-f]{2}:[0-9a-f]{2}):(?<ethtype>[0-9a-f]{2}:[0-9a-f]{2}) ' +
                   'SRC=(?<saddr>[^ ]*) DST=(?<daddr>[^ ]*) LEN=(?<len>[^ ]*) ' +
                   'TOS=(?<tos>[^ ]*) PREC=(?<prec>[^ ]*) TTL=(?<ttl>[^ ]*) ' +
                   'ID=(?<id>[^ ]*) (D*F*)\s*PROTO=(?<proto>[^ ' +
                   ']*)\s?((SPT=)?(?<sport>[0-9]*))\s?((DPT=)?(?<dport>[0-9]*))\s' +
                   '?((LEN=)?(?<protolen>[0-9]*))\s?((WINDOW=)?(?<window>[0-9]*))\s' +
                   '?((RES=)?(?<res>0?x?[0-9]*))\s?(?<flag>[^ ]*)\s?((URGP=)?(?<urgp>[0-9]*))',
        'time_key' => 'time',
        'time_format' => '%Y-%m-%dT%H:%M:%S.%L%z',
      },
    ],
  },
}
