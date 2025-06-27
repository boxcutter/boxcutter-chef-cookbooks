#
# Cookbook:: boxcutter_site_settings
# Recipe:: dnf
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

puts "MISCHA: #{node['platform']}"
puts "MISCHA: #{node['platform_version']}"

if node.centos?
  node.default['fb_yum_repos']['repos'] = value_for_platform(
    'centos' => {
      '9' => {
        'centos-addons' => {
          'description' => 'centos-addons.repo',
          'repos' => {
            'highavailability' => {
              'name' => 'CentOS Stream $releasever - HighAvailability',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-highavailability-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'countme' => '1',
              'enabled' => '0',
            },
            'highavailability-debug' => {
              'name' => 'CentOS Stream $releasever - HighAvailability - Debug',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-highavailability-debug-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
            'highavailability-source' => {
              'name' => 'CentOS Stream $releasever - HighAvailability - Source',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-highavailability-source-$stream&arch=source&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
            'nfv' => {
              'name' => 'CentOS Stream $releasever - NFV',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-nfv-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'countme' => '1',
              'enabled' => '0',
            },
            'nfv-debug' => {
              'name' => 'CentOS Stream $releasever - NFV - Debug',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-nfv-debug-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
            'nfv-source' => {
              'name' => 'CentOS Stream $releasever - NFV - Source',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-nfv-source-$stream&arch=source&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
            'rt' => {
              'name' => 'CentOS Stream $releasever - RT',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-rt-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'countme' => '1',
              'enabled' => '0',
            },
            'rt-debug' => {
              'name' => 'CentOS Stream $releasever - RT - Debug',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-rt-debug-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
            'rt-source' => {
              'name' => 'CentOS Stream $releasever - RT - Source',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-rt-source-$stream&arch=source&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
            'resilientstorage' => {
              'name' => 'CentOS Stream $releasever - ResilientStorage',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-resilientstorage-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'countme' => '1',
              'enabled' => '0',
            },
            'resilientstorage-debug' => {
              'name' => 'CentOS Stream $releasever - ResilientStorage - Debug',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-resilientstorage-debug-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
            'resilientstorage-source' => {
              'name' => 'CentOS Stream $releasever - ResilientStorage - Source',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-resilientstorage-source-$stream&arch=source&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
            'extras-common' => {
              'name' => 'CentOS Stream $releasever - Extras packages',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-extras-sig-extras-common-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Extras-SHA512',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'countme' => '1',
              'enabled' => '1',
            },
            'extras-common-source' => {
              'name' => 'CentOS Stream $releasever - Extras packages - Source',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-extras-sig-extras-common-source-$stream&arch=source&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Extras-SHA512',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
          },
        },
        'centos' => {
          'description' => 'centos.repo',
          'repos' => {
            'baseos' => {
              'name' => 'CentOS Stream $releasever - BaseOS',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-baseos-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'countme' => '1',
              'enabled' => '1',
            },
            'baseos-debuginfo' => {
              'name' => 'CentOS Stream $releasever - BaseOS - Debug',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-baseos-debug-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
            'baseos-source' => {
              'name' => 'CentOS Stream $releasever - BaseOS - Source',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-baseos-source-$stream&arch=source&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
            'appstream' => {
              'name' => 'CentOS Stream $releasever - AppStream',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-appstream-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'countme' => '1',
              'enabled' => '1',
            },
            'appstream-debuginfo' => {
              'name' => 'CentOS Stream $releasever - AppStream - Debug',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-appstream-debug-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
            'appstream-source' => {
              'name' => 'CentOS Stream $releasever - AppStream - Source',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-appstream-source-$stream&arch=source&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
            'crb' => {
              'name' => 'CentOS Stream $releasever - CRB',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-crb-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'countme' => '1',
              'enabled' => '1',
            },
            'crb-debuginfo' => {
              'name' => 'CentOS Stream $releasever - CRB - Debug',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-crb-debug-$stream&arch=$basearch&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
            'crb-source' => {
              'name' => 'CentOS Stream $releasever - CRB - Source',
              'metalink' => 'https://mirrors.centos.org/metalink?repo=centos-crb-source-$stream&arch=source&protocol=https,http',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
              'gpgcheck' => '1',
              'repo_gpgcheck' => '0',
              'metadata_expire' => '6h',
              'enabled' => '0',
            },
          },
        },
        'epel' => {
          'description' => 'epel.repo',
          'repos' => {
            'epel' => {
              'name' => 'Extra Packages for Enterprise Linux $releasever - $basearch',
              'metalink' => 'https://mirrors.fedoraproject.org/metalink?repo=epel-$releasever&arch=$basearch&infra=$infra&content=$contentdir',
              'enabled' => '1',
              'gpgcheck' => '1',
              'countme' => '1',
              'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$releasever',
            },
          },
        },
      },
    },
  )

  package 'epel-release' do
    action :upgrade
  end
end
