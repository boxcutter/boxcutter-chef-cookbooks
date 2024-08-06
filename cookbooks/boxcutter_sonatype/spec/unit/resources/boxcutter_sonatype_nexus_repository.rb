require 'chefspec'

describe 'boxcutter_sonatype_nexus_repository' do
  step_into :boxcutter_sonatype_nexus_repository
  platform 'ubuntu'

  default_attributes['boxcutter_sonatype']['nexus_repository'] = {
    'enable' => true,
    'admin_password' => nil,
    'properties' => {},
    'repositories' => {},
  }

  recipe do
    boxcutter_sonatype_nexus_repository 'test'
  end

  context 'default context' do
    before do
      allow(Boxcutter::Sonatype::Helpers).
        to receive(:repositories_list).
        and_return(
          [{
            'name' => 'nuget-hosted',
              'format' => 'nuget',
              'type' => 'hosted',
              'url' => 'http://127.0.0.1:2204/repository/nuget-hosted',
              'attributes' => {},
          }, {
            'name' => 'maven-snapshots',
              'format' => 'maven2',
              'type' => 'hosted',
              'url' => 'http://127.0.0.1:2204/repository/maven-snapshots',
              'attributes' => {},
          }, {
            'name' => 'nuget.org-proxy',
              'format' => 'nuget',
              'type' => 'proxy',
              'url' => 'http://127.0.0.1:2204/repository/nuget.org-proxy',
              'attributes' => {
                'proxy' => {
                  'remoteUrl' => 'https://api.nuget.org/v3/index.json',
                },
              },
          }, {
            'name' => 'maven-central',
              'format' => 'maven2',
              'type' => 'proxy',
              'url' => 'http://127.0.0.1:2204/repository/maven-central',
              'attributes' => {
                'proxy' => {
                  'remoteUrl' => 'https://repo1.maven.org/maven2/',
                },
              },
          }, {
            'name' => 'nuget-group',
              'format' => 'nuget',
              'type' => 'group',
              'url' => 'http://127.0.0.1:2204/repository/nuget-group',
              'attributes' => {},
          }, {
            'name' => 'maven-public',
              'format' => 'maven2',
              'type' => 'group',
              'url' => 'http://127.0.0.1:2204/repository/maven-public',
              'attributes' => {},
          }, {
            'name' => 'maven-releases',
              'format' => 'maven2',
              'type' => 'hosted',
              'url' => 'http://127.0.0.1:2204/repository/maven-releases',
              'attributes' => {},
          }],
          )
      allow(Boxcutter::Sonatype::Helpers).to receive(:repository_create).and_return('')
      allow(Boxcutter::Sonatype::Helpers).to receive(:repository_delete).and_return('')
    end

    puts 'HI'
    # it { is_expected.to write_log('Goodbye world') }
    it 'executes' do
      # allow_any_instance_of(Chef::Resource::ActionClass).to receive(:repositories).and_return([{"name" => "value"}])
      expect { chef_run }.to_not raise_error
      %w{
        nuget-hosted
        maven-snapshots
        nuget.org-proxy
        maven-central
        nuget-group
        maven-public
        maven-releases
      }.each do |repo|
        expect(Boxcutter::Sonatype::Helpers).to have_received(:repository_delete).with(repo)
      end
    end
  end
end
