unified_mode true

action :configure do
  local_ini_path = '/opt/couchdb/etc/local.ini'

  current_config = {}
  if ::File.exist?(local_ini_path)
    current_config = IniParse.parse(::File.read(local_ini_path))
  end

  puts "MISCHA current_config=#{current_config}"

  admin_password_hash = nil
  if current_config.has_section?('admins')
    admins_section = current_config['admins']
    if admins_section.has_option?(admin_username)
      admin_password_changed = Boxcutter::CouchDB::Helpers.verify_pbkdf2_hash(admin_password,
                                                                              admins_section[admin_username])
      puts "MISCHA: admin_password_changed=#{admin_password_changed}"
      if admin_password_changed
        puts "MISCHA: admin_password changed to #{admin_password}"
        admin_password_hash = Boxcutter::CouchDB::Helpers.generate_pbkdf2_password_hash(admin_password)
      else
        puts "MISCHA reusing existing password hash #{admin_password}"
        admin_password_hash = current_config['admins'][admin_username]
      end
    end
  end
  if admin_password_hash.nil?
    puts 'MISCHA: generating new password hash'
    admin_password_hash = Boxcutter::CouchDB::Helpers.generate_pbkdf2_password_hash(admin_password)
  end
  desired_config_document = IniParse.gen do |doc|
    node['boxcutter_couchdb']['local'].each do |config_section, options|
      case options
      when Hash
        doc.section(config_section) do |section|
          options.each do |key, value|
            section.option(key, value)
          end
        end
      end
    end
    doc.section('admins') do |admins|
      admins.option(admin_username, admin_password_hash)
    end
  end

  puts "MISCHA desired_config=#{desired_config_document.to_ini}"

  file local_ini_path do
    content lazy {
      desired_config_document.to_ini
    }
    owner 'couchdb'
    group 'couchdb'
    mode '0644'
    notifies :restart, 'service[couchdb]', :immediately
  end

  cookbook_file '/opt/couchdb/etc/local.d/99-local-options.ini' do
    owner 'couchdb'
    group 'couchdb'
    mode '0644'
    action :create_if_missing
    notifies :restart, 'service[couchdb]', :immediately
  end

  # /lib/systemd/system/couchdb.service
  service 'couchdb' do
    action [:enable, :start]
  end

  couchdb_host = '127.0.0.1'
  couchdb_port = '5984'

  %w{
    _users
    _replicator
    _global_changes
  }.each do |database_name|
    database_exist = Boxcutter::CouchDB::Helpers.couchdb_database_exist?(
      admin_username,
      admin_password,
      couchdb_host,
      couchdb_port,
      database_name,
    )

    unless database_exist
      Boxcutter::CouchDB::Helpers.couchdb_create_database(
        admin_username,
        admin_password,
        couchdb_host,
        couchdb_port,
        database_name,
      )
    end
  end
end

action_class do
  def run_state_or_attribute(attribute)
    if node.run_state.key?('boxcutter_couchdb') && node.run_state['boxcutter_couchdb'].key?(attribute)
      node.run_state['boxcutter_couchdb'][attribute]
    else
      node['boxcutter_couchdb'][attribute]
    end
  end

  def admin_username
    run_state_or_attribute('admin_username')
  end

  def admin_password
    run_state_or_attribute('admin_password')
  end
end
