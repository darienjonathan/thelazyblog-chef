#
# Cookbook:: rails
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

package "ImageMagick"

execute "nodejs rpm" do
  command "curl -sL https://rpm.nodesource.com/setup_6.x | sudo -E bash -"
end
package "nodejs"

execute "yarn repo" do
  command "wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo"
end
package "yarn"

template "#{node['blog']['dir']}/shared/.env.production" do
  source '.env.production.erb'
  owner node['user']['name']
  mode 0644
  variables({
    db_root_pass: node['db']['pass'],
    socket: node['db']['socket'],
    db_prod_pass: node['db']['prod_pass'],
    secret_key_base: node['secret_key_base']
   })
end