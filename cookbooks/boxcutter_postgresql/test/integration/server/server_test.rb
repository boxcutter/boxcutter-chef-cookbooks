# Make sure that the postgres user is managed by fb_users, and is using
# our special uid/gid
describe user('postgres') do
  it { should exist }
  its('uid') { should eq 700 }
  its('gid') { should eq 700 }
end

service_name = case os.family
               when 'debian'
                 'postgresql'
               when 'redhat', 'fedora', 'amazon'
                 'postgresql-16'
               else
                 'postgresql' # reasonable default
               end

describe service(service_name) do
  it { should be_enabled }
  it { should be_running }
end

describe port(5432) do
  it { should be_listening }
  its('protocols') { should include 'tcp' }
end

describe processes('postgres') do
  its('entries.length') { should be > 0 }
  its('users') { should include 'postgres' }
end

psql_command = \
  %{su --login postgres --command "psql -c 'SELECT version();'"}
describe command(psql_command) do
  its('stdout') { should match(/PostgreSQL \d+\.\d+/) }
  its('exit_status') { should eq 0 }
end

# https://www.digitalocean.com/community/tutorials/how-to-audit-a-postgresql-database-with-inspec-on-ubuntu-18-04
# describe postgres_conf('/etc/postgresql/16/main/postgresql.conf') do
#   its('unix_socket_directories') { should eq '.s.PGSQL.5432' }
#   its('unix_socket_group') { should eq nil }
#   its('unix_socket_permissions') { should eq '0770' }
# end

# describe postgres_hba_conf.where { type == 'local' } do
#   its('auth_method') { should all eq 'scram-sha-256' }
# end

# su - postgres
# psql
# SELECT rolname FROM pg_roles WHERE rolname = 'dev1';
# postgres = postgres_session('postgres', nil, 'localhost')
# describe postgres.query("SELECT 1 FROM pg_roles WHERE rolname = 'dev1';", ['postgres']) do
#   its('output') { should match /^1$/ }
# end
describe command("su - postgres -c \"psql -d postgres -c \\\"SELECT 1 FROM pg_roles WHERE rolname = 'dev1';\\\"\"") do
  its('stdout') { should match(/^\s*1\s*$/) }
end
