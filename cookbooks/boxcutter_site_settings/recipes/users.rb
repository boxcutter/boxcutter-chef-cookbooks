#
# Cookbook:: boxcutter_site_settings
# Recipe:: users
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

%w{
  root
  sudo
  users
}.each do |grp|
  FB::Users.initialize_group(node, grp)
end

# Ubuntu:
# /etc/group
# nobody:x:65534:
# /etc/passwd
# nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
if node.ubuntu?
  FB::Users.initialize_group(node, 'nogroup')
end
