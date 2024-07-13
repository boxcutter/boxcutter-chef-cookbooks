require './spec/spec_helper'

describe 'boxcutter_docker' do
  step_into :boxcutter_docker
  platform 'ubuntu'

  default_attributes['boxcutter_docker'] = {
    'enable' => true,
    'group' => 'docker',
    'config' => {
      'log-opts' => {
        'max-size' => '25m',
        'max-file' => '10',
      },
    },
    'buildkits' => {},
    'contexts' => {},
    'containers' => {},
    'bind_mounts' => {},
    'volumes' => {},
    'devices' => {},
    'networks' => {},
  }

  before do
    default_contexts = '{"Name":"default",' +
      '"Description":"Current DOCKER_HOST based configuration",' +
      '"DockerEndpoint":"unix:///var/run/docker.sock",' +
      '"Current":true,"Error":"","ContextType":"moby"}'
    stubs_for_provider('boxcutter_docker[test]') do |provider|
      allow(provider).to receive_shell_out(
        'docker context ls --format "{{json .}}"',
        stdout: default_contexts,
      )

      default_buildkits = <<~EOS
{"Name":"default","Driver":"docker","LastActivity":"0001-01-01T00:00:00Z","Dynamic":false,"Nodes":[{"Name":"default","Endpoint":"default","Status":"running","Version":"v0.14.1","IDs":["14fc91e1-dd76-49b1-94f0-466b5e122d91"],"Platforms":["linux/amd64","linux/amd64/v2","linux/amd64/v3","linux/amd64/v4","linux/386"],"Labels":{"org.mobyproject.buildkit.worker.moby.host-gateway-ip":"172.17.0.1"}}]}
{"Name":"default","Driver":"docker","LastActivity":"0001-01-01T00:00:00Z","Dynamic":false,"Nodes":[{"Name":"default","Endpoint":"default","Status":"running","Version":"v0.14.1","IDs":["14fc91e1-dd76-49b1-94f0-466b5e122d91"],"Platforms":["linux/amd64","linux/amd64/v2","linux/amd64/v3","linux/amd64/v4","linux/386"],"Labels":{"org.mobyproject.buildkit.worker.moby.host-gateway-ip":"172.17.0.1"}}]}
EOS
      allow(provider).to receive_shell_out(
        'docker buildx ls --format "{{json .}}"',
        stdout: default_buildkits,
      )

      default_networks = <<~EOS
{"CreatedAt":"2024-07-10 15:11:28.71133592 +0000 UTC","Driver":"bridge","ID":"e3efd0bc19cdcc9e8dbcfbebd8fb553e4c68168fcde0d051b3caf41fc6a59802","IPv6":"false","Internal":"false","Labels":"","Name":"bridge","Scope":"local"}
{"CreatedAt":"2024-07-10 15:11:25.117698682 +0000 UTC","Driver":"host","ID":"cd9b9c7af17d5d2bc7586e6989f569b6ef127b37b3e1f1cec16f19bbea308daf","IPv6":"false","Internal":"false","Labels":"","Name":"host","Scope":"local"}
{"CreatedAt":"2024-07-10 15:11:25.083738141 +0000 UTC","Driver":"null","ID":"5efa1b021c0f5cf1d87fb3e13815eb60f16709f24c1518b920e00958978f224b","IPv6":"false","Internal":"false","Labels":"","Name":"none","Scope":"local"}
EOS
      allow(provider).to receive_shell_out(
        'docker network ls --no-trunc --format "{{json .}}"',
        stdout: default_networks,
      )

      allow(provider).to receive_shell_out(
        'docker volume ls --format "{{json .}}"',
        stdout: '',
      )

      allow(provider).to receive_shell_out(
        'docker container ls --all --no-trunc --format "{{json .}}"',
        stdout: '',
      )
    end
  end

  recipe do
    boxcutter_docker 'test'
  end

  # contexts
  context 'default context' do
    default_attributes['boxcutter_docker']['contexts']['docker-test'] = {
      'docker' => 'host=tcp://docker:2375',
    }

    it {
      is_expected.to run_execute(
        'docker context create docker-test',
      ).with(
        command: 'docker context create docker-test ',
      )
    }
  end

  # buildkits
  context 'buildkits' do
    default_attributes['boxcutter_docker']['buildkits']['jetson'] = {
      'docker' => 'host=ssh://craft@10.63.34.181',
      'description' => 'NVIDIA Jetson',
    }

    it {
      is_expected.to run_execute('docker buildx create jetson')
    }
  end

  # networks
  context 'networks' do
    default_attributes['boxcutter_docker']['networks']['artifactory_network'] = {}

    it {
      is_expected.to run_execute('docker network create artifactory_network')
    }
  end

  # bind mounts
  context 'another' do
    it { is_expected.to_not create_directory('/opt/sonatype/sonatype-work') }
  end

  context 'bind mounts' do
    default_attributes['boxcutter_docker']['bind_mounts']['/opt/sonatype/sonatype-work'] = {}

    it { is_expected.to create_directory('/opt/sonatype/sonatype-work') }
  end

  # volumes
  context 'volumes' do
    default_attributes['boxcutter_docker']['volumes']['postgres_data'] = {}

    it {
      is_expected.to run_execute(
        'volume create postgres_data',
      ).with(
        command: 'docker volume create --driver local postgres_data',
      )
    }
  end

  # containers
  context 'container' do
    default_attributes['boxcutter_docker']['containers']['nexus3'] = {
      'image' => 'docker.io/sonatype/nexus3',
      'ports' => {
        '8081' => '8081',
      },
      'mounts' => {
        'nexus-data' => {
          'type' => 'bind',
          'source' => '/opt/sonatype/sonatype-work/nexus-data',
          'target' => '/nexus-data',
        },
      },
    }

    it {
      is_expected.to start_service('boxcutter_docker container nexus3')
    }
  end
end
