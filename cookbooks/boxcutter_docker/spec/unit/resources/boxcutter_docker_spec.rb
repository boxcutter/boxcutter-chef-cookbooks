require 'chefspec'

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
    'buildx' => {},
    'contexts' => {},
    'containers' => {},
    'bind_mounts' => {},
    'volumes' => {},
    'devices' => {},
    'networks' => {},
  }

  before do
    # contexts
    allow(Boxcutter::Docker::Helpers).
      to receive(:context_ls).
        and_return(
          [{"Name"=>"default",
            "Description"=>"Current DOCKER_HOST based configuration",
            "DockerEndpoint"=>"unix:///var/run/docker.sock",
            "Current"=>true,
            "Error"=>"",
            "ContextType"=>"moby"}]
        )
    allow(Boxcutter::Docker::Helpers).
      to receive(:context_create).with(any_args)
    allow(Boxcutter::Docker::Helpers).
      to receive(:context_rm).with(any_args)

    # buildx
    allow(Boxcutter::Docker::Helpers).
      to receive(:buildx_ls).with(any_args).and_return({})
    allow(Boxcutter::Docker::Helpers).
      to receive(:buildx_create).with(any_args)
    allow(Boxcutter::Docker::Helpers).
      to receive(:buildx_create_append).with(any_args)

    # networks
    allow(Boxcutter::Docker::Helpers).
      to receive(:network_ls).
        and_return(
          {"bridge"=>{"driver"=>"bridge", "labels"=>""},
           "host"=>{"driver"=>"host", "labels"=>""},
           "none"=>{"driver"=>"null", "labels"=>""}}
        )
    allow(Boxcutter::Docker::Helpers).
      to receive(:network_create).with(any_args)

    # volumes
    allow(Boxcutter::Docker::Helpers).
      to receive(:volume_ls).and_return({})
    allow(Boxcutter::Docker::Helpers).
      to receive(:volume_create).with(any_args)

    # containers
    allow(Boxcutter::Docker::Helpers).
      to receive(:container_ls).and_return({})
  end

  context 'with default' do
    default_attributes['boxcutter_docker']['buildx']['github-runner'] = {
      'home' => '/home/github-runner',
      'user' => 'github-runner',
      'group' => 'github-runner',
      'builders' => {
        'x86_64_builder' => {
          'name' => 'github-runner-x86-64-builder',
          'driver' => 'docker-container',
          'use' => true,
          'append' => {
            'github_runner_nvidia_jetson_agx_orin' => {
              'name' => 'github-runner-nvidia-jetson-agx-orin',
              'endpoint' => 'host=ssh://craft@10.63.34.15',
            },
          },
        },
      },
    }

    before do
      allow(Boxcutter::Docker::Helpers).
        to receive(:buildx_ls).with('/home/github-runner').
        and_return(
          {"x86-64-builder"=>
             {"Name"=>"x86-64-builder",
              "Driver"=>"docker-container",
              "Nodes"=>
                [{"Name"=>"x86-64-builder0",
                  "Endpoint"=>"unix:///var/run/docker.sock",
                  "Platforms"=>[],
                  "DriverOpts"=>nil,
                  "Flags"=>["--allow-insecure-entitlement=network.host"],
                  "Files"=>nil},
                 {"Name"=>"x86-64-builder1",
                  "Endpoint"=>"nvidia-jetson-agx-orin",
                  "Platforms"=>nil,
                  "DriverOpts"=>nil,
                  "Flags"=>["--allow-insecure-entitlement=network.host"],
                  "Files"=>nil}],
              "Dynamic"=>false}}
        )

      allow(Boxcutter::Docker::Helpers).
        to receive(:context_ls).with(any_args).
        and_return(
          [{"Name"=>"default",
            "Description"=>"Current DOCKER_HOST based configuration",
            "DockerEndpoint"=>"unix:///var/run/docker.sock",
            "Current"=>true,
            "Error"=>"",
            "ContextType"=>"moby"},
           {"Name"=>"nvidia-jetson-agx-orin",
            "Description"=>"",
            "DockerEndpoint"=>"ssh://craft@10.63.34.15",
            "Current"=>false,
            "Error"=>"",
            "ContextType"=>"moby"}]
          )

      allow(Boxcutter::Docker::Helpers).
        to receive(:context_create).with(any_args)
    end

    recipe do
      boxcutter_docker 'test'
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
