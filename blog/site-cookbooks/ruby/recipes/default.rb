#
# Cookbook:: ruby
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

bash "install rbenv" do
  user node['user']['name']
  environment ({"HOME" => "/home/#{node['user']['name']}"}) 
  cwd "/home/#{node['user']['name']}"
  code <<-EOH
    git clone git://github.com/sstephenson/rbenv.git /home/#{node['user']['name']}/.rbenv
    cd /home/#{node['user']['name']}/.rbenv && src/configure && make -C src
    echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' >> /home/#{node['user']['name']}/.bash_profile
    echo 'eval \"$(rbenv init -)\"' >> /home/#{node['user']['name']}/.bash_profile
    git clone https://github.com/sstephenson/ruby-build.git /home/#{node['user']['name']}/.rbenv/plugins/ruby-build
    echo 'export PATH=\"$HOME/.rbenv/plugins/ruby-build/bin:$PATH\"' >> /home/#{node['user']['name']}/.bash_profile
  EOH
  not_if { File.exists?("/home/#{node['user']['name']}/.rbenv/bin/rbenv") }
end

bash "source" do
  user node['user']['name']
  cwd "/home/#{node['user']['name']}"
  environment ({"HOME" => "/home/#{node['user']['name']}"}) 
  code "source /home/#{node['user']['name']}/.bash_profile"
end

bash "install ruby" do
  version_path = "/home/#{node['user']['name']}/.rbenv/version"
  user node['user']['name']
  environment ({"HOME" => "/home/#{node['user']['name']}"}) 
  cwd "/home/#{node['user']['name']}"
  code <<-EOH
    export HOME=/home/#{node['user']['name']}
    export RBENV_ROOT="${HOME}/.rbenv"
    export PATH="${RBENV_ROOT}/bin:${PATH}"
    rbenv install #{node['ruby']['version']}
    rbenv global #{node['ruby']['version']}
    rbenv rehash
    rbenv exec gem install bundler
    rbenv rehash
  EOH
  not_if { File.exists?(version_path) && `cat #{version_path}`.chomp.split[0] == node['ruby']['version'] }
end