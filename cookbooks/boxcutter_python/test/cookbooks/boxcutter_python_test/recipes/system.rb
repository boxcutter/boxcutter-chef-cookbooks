#
# Cookbook:: boxcutter_python_test
# Recipe:: system
#

include_recipe 'boxcutter_python::system'

boxcutter_python_virtualenv '/opt/certbot/venv' do
  prompt 'venv'
  copies true
  action :create
end

boxcutter_python_pip 'certbot' do
  virtualenv '/opt/certbot/venv'
  action :install
end

boxcutter_python_virtualenv '/opt/jinja/venv' do
  action :create
end

boxcutter_python_pip 'Jinja2' do
  version '2.8'
  virtualenv '/opt/jinja/venv'
end

boxcutter_python_virtualenv '/opt/deleteme' do
  action :create
  notifies :delete, 'boxcutter_python_virtualenv[delete /opt/deleteme]', :immediately
end

boxcutter_python_virtualenv 'delete /opt/deleteme' do
  path '/opt/deleteme'
  action :delete
end
