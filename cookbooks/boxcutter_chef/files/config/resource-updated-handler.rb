# While we could register a report handler and walk through
# `run_status.updated_resources`, we'll miss some resource updates
# like delayed updates or updates triggered indrectly.
Chef.event_handler do
  resource_updates = []
  on :resource_updated do |resource, action|
    next if resource.nil?

    resource_updates << {
      :name => "#{resource.resource_name}[#{resource.name}]",
      :cookbook => resource.cookbook_name,
      :recipe => resource.recipe_name,
      :line => resource.source_line,
      :action => action,
    }
  end

  on :run_completed do
    if resource_updates.empty?
      Chef::Log.info('No resources updated.')
    else
      Chef::Log.info("Updated #{resource_updates.size} resource(s):")
      resource_updates.each do |r|
        Chef::Log.info("  - #{r[:name]} (#{r[:cookbook]}::#{r[:recipe]} line #{r[:line]}) via :#{r[:action]}")
      end
    end
  end
end
