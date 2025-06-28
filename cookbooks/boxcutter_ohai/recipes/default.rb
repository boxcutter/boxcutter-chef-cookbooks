#
# Cookbook:: boxcutter_ohai
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

Chef.event_handler do
  on :run_completed do |node, run_status|
    puts 'MISCHA: run_completed handler'
  end
end

Chef.event_handler do
  resource_updates = []
  on :resource_updated do |resource, action|
    next if resource.nil?

    resource_updates << {
      name: "#{resource.resource_name}[#{resource.name}]",
      cookbook: resource.cookbook_name,
      recipe: resource.recipe_name,
      line: resource.source_line,
      action: action,
    }
  end

  on :run_completed do
    if resource_updates.empty?
      # Chef::Log.info('NEW: No resources updated.')
      puts('NEW: No resources updated.')
    else
      # Chef::Log.info("NEW: Updated #{resource_updates.size} resource(s):")
      puts("NEW: Updated #{resource_updates.size} resource(s):")
      resource_updates.each do |r|
        # Chef::Log.info("NEW:  - #{r[:name]} (#{r[:cookbook]}::#{r[:recipe]} line #{r[:line]}) via :#{r[:action]}")
      end
    end
  end
end

