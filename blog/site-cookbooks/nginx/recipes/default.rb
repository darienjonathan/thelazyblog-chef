#
# Cookbook:: nginx
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

execute "install nginx" do
  command "amazon-linux-extras install nginx1.12"
end

template "/etc/nginx/nginx.conf" do #di node nya tar ditaro di path/to/file (file name ya)
  source 'nginx.conf.erb' #filename start dari cookbook_name/templates/default
  owner node['user']['name']
  mode 0644
  variables({
    socket_name: node['sock']['name'],
    blog_dir: node['blog']['dir']
   }) #ini bs hash jg keliatannya
end

execute "systemctl start nginx"
