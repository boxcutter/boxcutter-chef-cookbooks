describe pip('certbot', '/opt/certbot/venv/bin/pip3') do
  it { should be_installed }
end

describe pip('certbot-dns-cloudflare', '/opt/certbot/venv/bin/pip3') do
  it { should be_installed }
end
