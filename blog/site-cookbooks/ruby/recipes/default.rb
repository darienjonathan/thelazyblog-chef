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

# RUBY_CONFIGURE_OPTS=--disable-install-doc on line 38
# to prevent `make: *** [rdoc] Killed` error, when installed on t3a.nano (2020/1)

bash "install ruby" do
  version_path = "/home/#{node['user']['name']}/.rbenv/version"
  user node['user']['name']
  environment ({"HOME" => "/home/#{node['user']['name']}"}) 
  cwd "/home/#{node['user']['name']}"
  code <<-EOH
    source /home/#{node['user']['name']}/.bash_profile
    export RUBY_CONFIGURE_OPTS=--disable-install-doc
    rbenv install #{node['ruby']['version']}
    rbenv global #{node['ruby']['version']}
    rbenv rehash
    rbenv exec gem install bundler
    rbenv rehash
  EOH
  not_if { File.exists?(version_path) && `cat #{version_path}`.chomp.split[0] == node['ruby']['version'] }
end
