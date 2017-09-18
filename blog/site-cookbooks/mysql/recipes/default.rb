#
# Cookbook:: mysql
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

package "mysql-server"
package "mysql-devel"
execute "service mysqld start"

bash "mysql-initialization" do
  code <<-EOH
    service mysqld start
    mysqladmin -u #{node['db']['user']} password #{node['db']['pass']}
  EOH
end

template "#{node['blog']['dir']}#{node['prod']['file']}" do
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
  command "mysql -u #{node['db']['user']} -p#{node['db']['pass']} < #{node['blog']['dir']}#{node['prod']['file']}"
end

file "#{node['blog']['dir']}#{node['prod']['file']}" do
  action :delete
end