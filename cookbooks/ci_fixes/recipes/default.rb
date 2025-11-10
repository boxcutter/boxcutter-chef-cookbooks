#
# Cookbook Name:: ci_fixes
# Recipe:: default
#
# Copyright (c) 2020-present, Facebook, Inc.
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# On centos-stream-10 you'll see the following error using the fb_systemd
# cookbook. To allow kitchen tests to run in CI, disable systemd-logind:
#
# STDERR: Failed to restart systemd-logind.service: Unit systemd-logind.service
# is masked.
# ---- End output of ["/usr/bin/systemctl", "--system", "restart",
# "systemd-logind"] ----
# Ran ["/usr/bin/systemctl", "--system", "restart", "systemd-logind"] returned 1
#
node.default['fb_systemd']['logind']['enable'] = false
