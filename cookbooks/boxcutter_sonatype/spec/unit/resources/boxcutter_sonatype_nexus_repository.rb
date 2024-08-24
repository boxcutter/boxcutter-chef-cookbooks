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
      allow(Boxcutter::Sonatype::Helpers).
        to receive(:repositories_settings_list).
        and_return(
          [{
             'name' => 'ros-proxy',
             'url' => 'http://127.0.0.1:8081/repository/ros-proxy',
             'online' => true,
             'storage' => {
               'blobStoreName' => 'default',
               'strictContentTypeValidation' => true,
               'writePolicy' => 'ALLOW',
             },
             'cleanup' => {
               'policyNames' => [ ],
             },
             'apt' => {
               'distribution' => 'jammy',
               'flat' => false,
             },
               'proxy' => {
               'remoteUrl' => 'http://packages.ros.org/ros2/ubuntu',
               'contentMaxAge' => 1440,
               'metadataMaxAge' => 1440,
             },
             'negativeCache' => {
               'enabled' => true,
               'timeToLive' => 1440,
             },
             'httpClient' => {
               'blocked' => false,
               'autoBlock' => true,
               'connection' => {
                 'retries' => 0,
                 'userAgentSuffix' => null,
                 'timeout' => 60,
                 'enableCircularRedirects' => false,
                 'enableCookies' => false,
                 'useTrustStore' => false,
               },
               'authentication' => null,
             },
             'routingRuleName' => null,
             'format' => 'apt',
             'type' => 'proxy',
           }, {
             'name' => 'testy-hosted',
             'url' => 'http://127.0.0.1:8081/repository/testy-hosted',
             'online' => true,
             'storage' => {
               'blobStoreName' => 'default',
               'strictContentTypeValidation' => true,
               'writePolicy' => 'allow',
             },
             'cleanup' => {
               'policyNames' => [ ],
             },
             'component' => {
               'proprietaryComponents' => false,
             },
             'raw' => {
               'contentDisposition' => 'ATTACHMENT',
             },
             'format' => 'raw',
             'type' => 'hosted',
           }, {
             'name' => 'docker-proxy',
             'url' => 'http://127.0.0.1:8081/repository/docker-proxy',
             'online' => true,
             'storage' => {
               'blobStoreName' => 'default',
               'strictContentTypeValidation' => true,
               'writePolicy' => 'ALLOW',
             },
             'cleanup' => {
               'policyNames' => [ ],
             },
             'docker' => {
               'v1Enabled' => true,
               'forceBasicAuth' => true,
               'httpPort' => 10080,
               'httpsPort' => 10443,
               'subdomain' => null,
             },
             'dockerProxy' => {
               'indexType' => 'HUB',
               'indexUrl' => 'https://index.docker.io/',
               'cacheForeignLayers' => true,
               'foreignLayerUrlWhitelist' : [ ],
             },
             'proxy' => {
               'remoteUrl' => 'https://registry-1.docker.io',
               'contentMaxAge' => 1440,
               'metadataMaxAge' => 1440,
             },
             'negativeCache' => {
               'enabled' => true,
               'timeToLive' => 1440,
             },
             'httpClient' => {
               'blocked' => false,
               'autoBlock' => true,
               'connection' => {
                 'retries' => 0,
                 'userAgentSuffix' => null,
                 'timeout' => 60,
                 'enableCircularRedirects' => false,
                 'enableCookies' => false,
                 'useTrustStore' => false,
               },
               'authentication' => null,
             },
             'routingRuleName' => null,
             'format' => 'docker',
             'type' => 'proxy',
           }]
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
