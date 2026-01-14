#
# Cookbook:: boxcutter_postgresql
# Recipe:: common
#
# Copyright:: 2025-present, Taylor.dev, LLC
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

case node['platform']
when 'ubuntu'
  # https://www.postgresql.org/download/linux/ubuntu/
  node.default['fb_apt']['sources']['postgresql'] = {
    'key' => 'postgresql',
    'url' => 'https://apt.postgresql.org/pub/repos/apt',
    'suite' => "#{node['lsb']['codename']}-pgdg",
    'components' => ['main'],
  }

  # curl -fsSLO https://www.postgresql.org/media/keys/ACCC4CF8.asc
  node.default['fb_apt']['keymap']['postgresql'] = <<~EOS
    -----BEGIN PGP PUBLIC KEY BLOCK-----

    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
    =DA1T
    -----END PGP PUBLIC KEY BLOCK-----
  EOS
when 'centos'
  # https://www.postgresql.org/download/linux/redhat/
  # sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
  case node['kernel']['machine']
  when 'x86_64', 'amd64'
    postgresql_gpgkey = 'https://download.postgresql.org/pub/repos/yum/keys/PGDG-RPM-GPG-KEY-RHEL'
  when 'aarch64', 'arm64'
    postgresql_gpgkey = 'https://download.postgresql.org/pub/repos/yum/keys/PGDG-RPM-GPG-KEY-AARCH64-RHEL'
  end

  node.default['fb_yum_repos']['repos']['postgresql'] = {
    'repos' => {
      'pgdg-common' => {
        'name' => 'PostgreSQL common RPMs for RHEL / Rocky / AlmaLinux $releasever - $basearch',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch',
        'enabled' => true,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      # Red Hat recently breaks compatibility between 9.n and 9.n+1. PGDG repo is
      # affected with the LLVM packages. This is a band aid repo for the llvmjit users
      # whose installations cannot be updated.
      'pgdg-rhel9-sysupdates' => {
        'name' => 'PostgreSQL Supplementary ucommon RPMs for RHEL / Rocky / AlmaLinux $releasever - $basearch',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-$releasever-$basearch',
        'enabled' => false,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      # We provide extra package to support some RPMs in the PostgreSQL RPM repo, like
      # consul, haproxy, etc.
      'pgdg-rhel9-extras' => {
        'name' => 'Extra packages to support some RPMs in the PostgreSQL RPM repo RHEL / Rocky / AlmaLinux ' \
                  '$releasever - $basearch',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch',
        'enabled' => false,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      'pgdg17' => {
        'name' => 'PostgreSQL 17 for RHEL / Rocky / AlmaLinux $releasever - $basearch',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/17/redhat/rhel-$releasever-$basearch',
        'enabled' => true,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      'pgdg16' => {
        'name' => 'PostgreSQL 16 for RHEL / Rocky / AlmaLinux $releasever - $basearch',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/16/redhat/rhel-$releasever-$basearch',
        'enabled' => true,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      'pgdg15' => {
        'name' => 'PostgreSQL 15 for RHEL / Rocky / AlmaLinux $releasever - $basearch',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/15/redhat/rhel-$releasever-$basearch',
        'enabled' => true,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      'pgdg14' => {
        'name' => 'PostgreSQL 14 for RHEL / Rocky / AlmaLinux $releasever - $basearch',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/14/redhat/rhel-$releasever-$basearch',
        'enabled' => true,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      'pgdg13' => {
        'name' => 'PostgreSQL 13 for RHEL / Rocky / AlmaLinux $releasever - $basearch',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-$releasever-$basearch',
        'enabled' => true,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      # PGDG RHEL / Rocky / AlmaLinux Updates Testing common repositories.
      'pgdg-common-testing' => {
        'name' => 'PostgreSQL common testing RPMs for RHEL / Rocky / AlmaLinux $releasever - $basearch',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/testing/common/redhat/rhel-$releasever-$basearch',
        'enabled' => false,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      # PGDG RHEL / Rocky / AlmaLinux Updates Testing repositories. (These packages should not be used in production)
      # Available for 13 and above.
      'pgdg18-updates-testing' => {
        'name' => 'PostgreSQL 18 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Updates testing',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/testing/18/redhat/rhel-$releasever-$basearch',
        'enabled' => false,
        'gpgcheck' => false,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      'pgdg17-updates-testing' => {
        'name' => 'PostgreSQL 17 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Updates testing',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/testing/17/redhat/rhel-$releasever-$basearch',
        'enabled' => false,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      'pgdg16-updates-testing' => {
        'name' => 'PostgreSQL 16 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Updates testing',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/testing/16/redhat/rhel-$releasever-$basearch',
        'enabled' => false,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      'pgdg15-updates-testing' => {
        'name' => 'PostgreSQL 15 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Updates testing',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/testing/15/redhat/rhel-$releasever-$basearch',
        'enabled' => false,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      'pgdg14-updates-testing' => {
        'name' => 'PostgreSQL 14 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Updates testing',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/testing/14/redhat/rhel-$releasever-$basearch',
        'enabled' => false,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      'pgdg13-updates-testing' => {
        'name' => 'PostgreSQL 13 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Updates testing',
        'baseurl' => 'https://download.postgresql.org/pub/repos/yum/testing/13/redhat/rhel-$releasever-$basearch',
        'enabled' => false,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      # PGDG Red Hat Enterprise Linux / Rocky SRPM testing common repository
      'pgdg-common-source' => {
        'name' => 'PostgreSQL common for RHEL / Rocky / AlmaLinux $releasever - $basearch - Source',
        'baseurl' => 'https://dnf-srpms.postgresql.org/srpms/common/redhat/rhel-$releasever-$basearch',
        'enabled' => false,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      # PGDG RHEL / Rocky / AlmaLinux testing common SRPM repository for all PostgreSQL versions
      'pgdg-common-testing-source' => {
        'name' => 'PostgreSQL common testing SRPMs for RHEL / Rocky / AlmaLinux $releasever - $basearch',
        'baseurl' => 'https://dnf-srpms.postgresql.org/srpms/testing/common/redhat/rhel-$releasever-$basearch',
        'enabled' => false,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      'pgdg18-updates-testing-source' => {
        'name' => 'PostgreSQL 18 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Source updates testing',
        'baseurl' => 'https://dnf-srpms.postgresql.org/srpms/testing/18/redhat/rhel-$releasever-$basearch',
        'enabled' => false,
        'gpgcheck' => true,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => true,
      },
      'pgdg17-source' => {
        'name' => 'PostgreSQL 17 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Source',
        'baseurl' => 'https://dnf-srpms.postgresql.org/srpms/17/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg17-updates-testing-source' => {
        'name' => 'PostgreSQL 17 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Source updates testing',
        'baseurl' => 'https://dnf-srpms.postgresql.org/srpms/testing/17/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg16-source' => {
        'name' => 'PostgreSQL 16 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Source',
        'baseurl' => 'https://dnf-srpms.postgresql.org/srpms/16/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg16-updates-testing-source' => {
        'name' => 'PostgreSQL 16 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Source updates testing',
        'baseurl' => 'https://dnf-srpms.postgresql.org/srpms/testing/16/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg15-source' => {
        'name' => 'PostgreSQL 15 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Source',
        'baseurl' => 'https://dnf-srpms.postgresql.org/srpms/15/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg15-updates-testing-source' => {
        'name' => 'PostgreSQL 15 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Source updates testing',
        'baseurl' => 'https://dnf-srpms.postgresql.org/srpms/testing/15/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg14-source' => {
        'name' => 'PostgreSQL 14 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Source',
        'baseurl' => 'https://dnf-srpms.postgresql.org/srpms/14/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg14-updates-testing-source' => {
        'name' => 'PostgreSQL 14 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Source updates testing',
        'baseurl' => 'https://dnf-srpms.postgresql.org/srpms/testing/14/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg13-source' => {
        'name' => 'PostgreSQL 13 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Source',
        'baseurl' => 'https://dnf-srpms.postgresql.org/srpms/13/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg13-updates-testing-source' => {
        'name' => 'PostgreSQL 13 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Source updates testing',
        'baseurl' => 'https://dnf-srpms.postgresql.org/srpms/testing/13/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      # Debuginfo/debugsource repositories for the common repo
      'pgdg-common-debuginfo' => {
        'name' => 'PostgreSQL common RPMs for RHEL / Rocky / AlmaLinux $releasever - $basearch - Debuginfo',
        'baseurl' => 'https://dnf-debuginfo.postgresql.org/debug/common/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      # Debuginfo/debugsource packages for stable repos
      'pgdg17-debuginfo' => {
        'name' => 'PostgreSQL 17 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Debuginfo',
        'baseurl' => 'https://dnf-debuginfo.postgresql.org/debug/17/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg16-debuginfo' => {
        'name' => 'PostgreSQL 16 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Debuginfo',
        'baseurl' => 'https://dnf-debuginfo.postgresql.org/debug/16/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg15-debuginfo' => {
        'name' => 'PostgreSQL 15 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Debuginfo',
        'baseurl' => 'https://dnf-debuginfo.postgresql.org/debug/15/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg14-debuginfo' => {
        'name' => 'PostgreSQL 14 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Debuginfo',
        'baseurl' => 'https://dnf-debuginfo.postgresql.org/debug/14/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg13-debuginfo' => {
        'name' => 'PostgreSQL 13 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Debuginfo',
        'baseurl' => 'https://dnf-debuginfo.postgresql.org/debug/13/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      # Debuginfo/debugsource packages for testing repos
      # Available for 13 and above.
      'pgdg18-updates-testing-debuginfo' => {
        'name' => 'PostgreSQL 18 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Debuginfo',
        'baseurl' => 'https://dnf-debuginfo.postgresql.org/testing/debug/18/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 0,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg17-updates-testing-debuginfo' => {
        'name' => 'PostgreSQL 17 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Debuginfo',
        'baseurl' => 'https://dnf-debuginfo.postgresql.org/testing/debug/17/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg16-updates-testing-debuginfo' => {
        'name' => 'PostgreSQL 16 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Debuginfo',
        'baseurl' => 'https://dnf-debuginfo.postgresql.org/testing/debug/16/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg15-updates-testing-debuginfo' => {
        'name' => 'PostgreSQL 15 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Debuginfo',
        'baseurl' => 'https://dnf-debuginfo.postgresql.org/testing/debug/15/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg14-updates-testing-debuginfo' => {
        'name' => 'PostgreSQL 14 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Debuginfo',
        'baseurl' => 'https://dnf-debuginfo.postgresql.org/testing/debug/14/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
      'pgdg13-updates-testing-debuginfo' => {
        'name' => 'PostgreSQL 13 for RHEL / Rocky / AlmaLinux $releasever - $basearch - Debuginfo',
        'baseurl' => 'https://dnf-debuginfo.postgresql.org/testing/debug/13/redhat/rhel-$releasever-$basearch',
        'enabled' => 0,
        'gpgcheck' => 1,
        'gpgkey' => postgresql_gpgkey,
        'repo_gpgcheck' => 1,
      },
    },
  }
end
