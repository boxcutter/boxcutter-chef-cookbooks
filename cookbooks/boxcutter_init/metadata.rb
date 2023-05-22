name 'boxcutter_init'
maintainer 'Boxcutter'
maintainer_email 'noreply@boxcutter.io'
license 'Apache-2.0'
description 'Setup a base runlist for using Facebook cookbooks'
source_url 'https://github.com/boxcutter/boxcutter-chef-cookbooks/'
version '0.0.1'
chef_version '>= 16.0'
%w{
  centos
  debian
  ubuntu
}.each do |p|
  supports p
end
depends 'fb_apt'
depends 'fb_rpm'
