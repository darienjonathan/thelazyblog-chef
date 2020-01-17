#
# Cookbook:: mysql
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

package "mariadb-server"
package "mariadb-devel"

cookbook_file '/etc/my.cnf' do
  source 'my.cnf'
end

file '/var/log/mysqld.log' do
  owner 'mysql'
  group 'mysql'
  mode '0755'
  action :touch
end

directory '/var/lib/mysql' do
  owner 'mysql'
  group 'mysql'
  mode '0755'
  action :create
end

directory '/var/run/mysqld' do
  owner 'mysql'
  group 'mysql'
  mode '0755'
  action :create
end

execute "systemctl start mariadb.service"

bash "mysql-initialization" do
  code <<-EOH
    systemctl start mariadb.service
    mysqladmin -u #{node['db']['user']} password #{node['db']['pass']}
  EOH
end

template "#{node['blog']['dir']}/#{node['prod']['file']}" do
  source "production.sql.erb"
  owner node['user']['name']
  mode 0644
  variables({
    name: node['blog']['name'],
    host: node['db']['host'],
    pass: node['db']['prod_pass']
    })
end

execute "add production db" do
  command "mysql -u #{node['db']['user']} -p#{node['db']['pass']} < #{node['blog']['dir']}/#{node['prod']['file']}"
end

file "#{node['blog']['dir']}/#{node['prod']['file']}" do
  action :delete
end
