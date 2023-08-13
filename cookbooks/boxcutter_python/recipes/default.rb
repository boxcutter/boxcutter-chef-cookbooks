#
# Cookbook:: boxcutter_python
# Recipe:: default
#
# Copyright:: 2023, Boxcutter
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

case node['platform_family']
when 'rhel'
  package %w(
      git
      gcc
      zlib-devel
      bzip2
      bzip2-devel
      readline-devel
      sqlite
      sqlite-devel
      openssl-devel
      tk-devel
      libffi-devel
      xz-devel
    ) do
    action :upgrade
  end
when 'debian'
  package %w(
      build-essential
      git
      libssl-dev
      zlib1g-dev
      libbz2-dev
      libreadline-dev
      libsqlite3-dev
      wget
      curl
      llvm
      libncursesw5-dev
      xz-utils
      tk-dev
      libxml2-dev
      libxmlsec1-dev
      libffi-dev
      liblzma-dev
    ) do
    action :upgrade
  end
end

boxcutter_python_pyenv 'manage'
