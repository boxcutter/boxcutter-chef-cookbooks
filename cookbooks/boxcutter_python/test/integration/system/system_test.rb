describe pip('certbot', '/opt/certbot/venv/bin/pip3') do
  it { should be_installed }
end

describe pip('Jinja2', '/opt/jinja/venv/bin/pip3') do
  it { should be_installed }
  its('version') { should eq '2.8' }
end

describe directory('/opt/deleteme') do
  it { should_not exist }
end
