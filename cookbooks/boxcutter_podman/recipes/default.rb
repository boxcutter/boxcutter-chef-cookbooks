#
# Cookbook:: boxcutter_podman
# Recipe:: default
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

if node.ubuntu20?
  node.default['fb_apt']['repos'] <<
    'deb https://download.opensuse.org/repositories/devel:/kubic:/' +
      "libcontainers:/stable/xUbuntu_#{node['lsb']['release']}/ /"

  # https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_20.04/Release.key
  node.default['fb_apt']['keys']['4D64390375060AA4'] = <<~EOS
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    Version: GnuPG v1.4.5 (GNU/Linux)

    mQENBFtkV0cBCADStSTCG5qgYtzmWfymHZqxxhfwfS6fdHJcbGUeXsI5dxjeCWhs
    XarZm6rWZOd5WfSmpXhbKOyM6Ll+6bpSl5ICHLa6fcpizYWEPa8fpg9EGl0cF12G
    GgVLnnOZ6NIbsoW0LHt2YN0jn8xKVwyPp7KLHB2paZh+KuURERG406GXY/DgCxUx
    Ffgdelym/gfmt3DSq6GAQRRGHyucMvPYm53r+jVcKsf2Bp6E1XAfqBrD5r0maaCU
    Wvd7bi0B2Q0hIX0rfDCBpl4rFqvyaMPgn+Bkl6IW37zCkWIXqf1E5eDm/XzP881s
    +yAvi+JfDwt7AE+Hd2dSf273o3WUdYJGRwyZABEBAAG0OGRldmVsOmt1YmljIE9C
    UyBQcm9qZWN0IDxkZXZlbDprdWJpY0BidWlsZC5vcGVuc3VzZS5vcmc+iQE+BBMB
    CAAoBQJjkECIAhsDBQkMSplBBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRBN
    ZDkDdQYKpPVfCACZNU7GNUKkTWQMsnefRe3x8xq7MXKYO8DC5rt1fVKQEbRl41Jo
    bMGMUyfCM4piB6feo8pENmSGLwSltZfXj4iWfwaOvk3vRGzLs2LJn2u9qIp9m9pK
    Dl7DqfOXFWv/7gnjKsZM0faioGZB75hQKFlD11KJNm20wo1jlP+Km8aaT/wVhN6i
    5ilLh9L7E5iTskCYTBGwmxJV6LlXkGPytVQ+86bmMWVMPJ1yZCb9scIPGxDNoLxx
    eefYEeaj4L4GoY28LiYPDjPT8crmBKJyV6EHaa5XijaQFRGqov9CWch4lctGMEvY
    TU2bkgXxhfhvJnOzdDDQEPIOc8R3DVeyL8dxiEYEExECAAYFAltkV0cACgkQOzAR
    t2udZSOoswCdF44NTN09DwhPFbNYhEMb9juP5ykAn0bcELvuKmgDwEwZMrPQkG8t
    Pu9n
    =YclD
    -----END PGP PUBLIC KEY BLOCK-----
  EOS
end

package 'podman' do
  action :upgrade
end
