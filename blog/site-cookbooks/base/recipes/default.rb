package "gcc"
package "gcc-c++"
package "make"
package "bzip2"
package "openssl-devel"
package "libyaml-devel"
package "libffi-devel"
package "readline-devel"
package "zlib-devel"
package "gdbm-devel"
package "ncurses-devel"
package "git"

# create user and add to group
user node['user']['name'] do
  home "/home/#{node['user']['name']}"
  password node['user']['pass']
  shell "/bin/bash"
  supports manage_home: true # need for /home creation
  not_if "getent passwd #{node['user']['name']}"
end

# give group sudo privileges
bash "give group sudo privileges" do
  code <<-EOH
    sed -i '/%#{node['group']}.*/d' /etc/sudoers
    echo '%#{node['group']} ALL=(ALL) ALL' >> /etc/sudoers
  EOH
  not_if "grep -xq '%#{node['group']} ALL=(ALL) ALL' /etc/sudoers"
end

directory "#{node["blog"]["dir"]}" do
  owner node['user']['name']
  group node['group']
  mode '0755'
  action :create
  recursive true
end

directory "#{node["blog"]["dir"]}/shared" do
  owner node['user']['name']
  group node['group']
  mode '0755'
  action :create
end