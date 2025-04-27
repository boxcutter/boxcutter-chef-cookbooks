describe command('psql --version') do
  its('stdout') { should match(/psql \(PostgreSQL\) \d+\.\d+/) }
  its('exit_status') { should eq 0 }
end
