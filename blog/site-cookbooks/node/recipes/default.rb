#
# Cookbook:: node
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

bash "install ndenv" do
  user node['user']['name']
  environment ({"HOME" => "/home/#{node['user']['name']}"}) 
  cwd "/home/#{node['user']['name']}"
  code <<-EOH
    git clone git://github.com/riywo/ndenv.git /home/#{node['user']['name']}/.ndenv
    cd /home/#{node['user']['name']}/.ndenv && src/configure && make -C src
    echo 'export PATH=\"$HOME/.ndenv/bin:$PATH\"' >> /home/#{node['user']['name']}/.bash_profile
    echo 'eval \"$(ndenv init -)\"' >> /home/#{node['user']['name']}/.bash_profile
    git clone https://github.com/riywo/node-build.git /home/#{node['user']['name']}/.ndenv/plugins/node-build
    echo 'export PATH=\"$HOME/.ndenv/plugins/node-build/bin:$PATH\"' >> /home/#{node['user']['name']}/.bash_profile
  EOH
  not_if { File.exists?("/home/#{node['user']['name']}/.ndenv/bin/ndenv") }
end

bash "source" do
  user node['user']['name']
  cwd "/home/#{node['user']['name']}"
  environment ({"HOME" => "/home/#{node['user']['name']}"}) 
  code "source /home/#{node['user']['name']}/.bash_profile"
end

bash "install node" do
  version_path = "/home/#{node['user']['name']}/.ndenv/version"
  user node['user']['name']
  environment ({"HOME" => "/home/#{node['user']['name']}"}) 
  cwd "/home/#{node['user']['name']}"
  code <<-EOH
    export HOME=/home/#{node['user']['name']}
    export RBENV_ROOT="${HOME}/.ndenv"
    export PATH="${RBENV_ROOT}/bin:${PATH}"
    ndenv install #{node['node']['version']}
    ndenv global #{node['node']['version']}
    ndenv rehash
    ndenv exec gem install bundler
    ndenv rehash
  EOH
  not_if { File.exists?(version_path) && `cat #{version_path}`.chomp.split[0] == node['node']['version'] }
end