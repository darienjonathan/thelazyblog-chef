
# thelazyblog-chef
This repository is used to provision the server which http://darienjonathan.com is running on the top of, and to deploy the codes from [this repository](https://github.com/darienjonathan/thelazyblog) to http://darienjonathan.com.

this repository makes use of two tools (ruby gems):
* [Chef](https://www.chef.io/chef/): a tool to for server provisioning. In this repository, it is used to provision server(s) to be able to run basic rails projects. Since chef is overkill (re: too complicated) to be used to deploy only to one server, to simplify the provisioning process, I use [knife-solo](https://matschaffer.github.io/knife-solo/) in conjunction with Chef.
* [Capistrano](https://github.com/capistrano/capistrano): a tool to deploy codes from a git repository to specified server(s). In this repository, it is used to deploy basic rails projects.

By the way, what is provisioning? Provisioning is to install/setup the environment of a server. By using chef, you can setup a remote server’s environment from your own local workstation without the need to enter the remote server (you should be able to do so, though, or else the tool also won’t be able to do so). Setup remote, from local (in one command). Thats the concept.

And what is deployment? It is to `copy/paste` your code from repository to your server, so you have the working code in your server without the need to enter the remote server (you should be able to do so, though, or else the tool also won’t be able to do so). 
Develop in local, push to repository, deploy to remote from local (in one command). Thats the concept.

See? Both are aimed to:
* eliminate the need to enter your remote server to manually do things, and
* to do things in one command.

AUTOMATE ALL THE TASKS!

## How to run the scripts
**Make sure to read the explanations below to understand what is happening!**

First, `git clone https://github.com/darienjonathan/thelazyblog-chef /path/to/dir`. Then:

### Chef
1. `cd /path/to/dir/blog`
2. configure the scripts based on your needs (explanation below)
3. `knife-solo bootstrap username@address`

### Enabling Deploy User to Connect to Remote
If you’re using different username to deploy, do this so capistrano can connect to your server:
1. SSH to your remote server
2. `mkdir /home/{deploy_username}/.ssh`
3. `cp .ssh/authorized_keys /home/{deploy_username}/.ssh/authorized_keys`
4. `chown {deploy_username}:{deploy_group} /home/{deploy_username}/.ssh/authorized_keys` 
5. `chown {deploy_username}:{deploy_group} /home/{deploy_username}/.ssh/`

### Capistrano
1. `cd /path/to/dir`
2. `bundle install --path=vendor/bundle`
3. configure the scripts based on your needs (explanation below)
4. `bundle exec capistrano production deploy` (or any tasks that suits your needs) 

## Chef
What are you doing when you want to setup an empty server?
* yum install this, yum install that (or change yum with apt-get if you’re running an ubuntu server),
* execute those commands,
* start these services,
* clone those tools from github,
* tweak that tool’s config so it suits your needs,
* and so on.

Chef does that for you, if you write the scripts properly.

Anyway, the name `Chef` comes from this analogy:
* the remote server you want to setup is a dish you want to make,
* since you need to know how to cook the dish, you want to have `cookbooks` that contains the `recipes` about how you `cook` that dish,
* and you are the `Chef`. You read `cookbooks` created by the others and `cook` the dish based on the `recipes` you have been given, or you just simply create your own `cookbooks` and `cook` the dish based of your own liking.
* And to cook the dishes, you want to have a `kitchen`, a place to cook. The directories that contains Chef configurations are called `kitchen`.

### Installation
Prerequisites: Ruby installed in your local machine, and obviously a remote machine to be provisioned.
Steps: `gem install chef`, then `gem install knife-solo` if you want to install `knife-solo` globally.
If you have a bundler, and you want to install it locally, put this in your `Gemfile`,
```ruby
group 'development' do
  gem 'knife-solo'
end
```
then run `bundle install --path=vendor/bundle`

### Overview
Most basic directories to be used in chef scripts are:
* `data_bags`: to save sensitive informations
* `roles`: to list which `cookbooks` should be used in the provisioning process. To manage the provisioning process, you can specify different `roles` to run appropriate `cookbooks` (e.g. db role to run db related cookbooks, app role to run app related cookbooks).
* `nodes` - a json file used to:
  * to specify the ip address of the target server (filename: ip_address.json) - if your target server’s IP address is 192.168.0.100, then the file name should be `192.168.0.1.json`.
  * to define some variables used in provisioning
  * to list what roles should be executed
* `cookbooks`: contain scripts downloaded from the [library](https://supermarket.chef.io/), or in their terms: `supermarket`.
* `site-cookbooks`: contain self-written scripts.

Basic provisioning flow:
1. `knife solo init {/path/to/dir}` -> prepare the necessary files to `/path/to/dir` in your local workstation. Creates the directory there isn’t one.
2. `knife solo prepare username@address` -> prepare the remote server for the provisioning process by downloading chef utilities
3. `knife solo cook username@address` -> provision the remote server with the written script
4. `knife solo bootstrap username@address` (`prepare` + `cook`)

Basic script-writing flow:
1. write/download provisioning scripts to `site-cookbooks`/`cookbooks` directory
2. specify which cookbook(s) should be run by a particular `role`
3. specify which role(s) should be run by a particular `node`
While doing above, you can utilize `data_bags` to store sensitive informations, and `node(s)` to store variables being used accross `cookbooks`.

overall: `knife solo init {directory_name}`  -> write the scripts ->  `knife solo bootstrap username@address`

### This Repository’s Cookbooks
This repository does not use library’s cookbook (all is written by myself - this is a repository for practice, after all), so everything is written in site-cookbooks directory. These cookbooks are also tailored specifically to provide necessary setups to http://darienjonathan.com
* base
  * installs the prerequisites to be able to install ruby properly
  * creates user, give group sudo privilege to it, and create its home directory (this user will be used to deploy an app by capistrano later).
  * creates the directory for the app
  * creates the shared directory to be used by capistrano later
* mysql
  * installs mysql
  * initializes mysql (run the service, add root password)
  * add a necessary mysql command to create mysql users for production database to be used by a rails app (look at templates folder)
* ruby
  * installs `rbenv` (ruby version controller) - a godlike tool to install and manage your ruby versions
  * installs `ruby-build` - a supplementary tool for `rbenv` to install ruby easily
  * installs ruby through `ruby-build`
  * installs `bundler` - a package manager for ruby
* nginx
  * installs nginx
  * generate custom `nginx.conf` (look at templates folder)
* rails
  * installs `ImageMagick` to be used by rails apps that utilizes `mini_magick` to use and manipulate pictures
  * installs `nodejs`
  * installs `yarn`
  * generates `.env.production` to be used by app later (look at templates folder). 

FYI: `.env.production` is a file that contains the computer (or workstation, or server, or instance, whatever)’s environment variables. Since the variables contained in it are usually sensitive (passwords, API keys, etc), you won’t see it in git, and in here, it is dynamically generated by variables, so you get to know what variables are needed to run http://darienjonathan.com (which is all standard to run a simple rails apps), but you don’t get to know the value of each variables. In the app, it is managed by a ruby gem `dotenv`.

Until this point, there is no rails installation, which is kinda weird remembering that this script is supposed to provide the necessary setup to run rails.
But yes. This is enough. Since rails is the part of the app, not the server environment, the actual rails installation is managed by capistrano.

> You need to run this in correct order - Chef runs the cookbook according to the order listed on `roles` or `nodes` directory

### Understanding Cookbooks
When you look at the cookbooks described above, you want to look at these important directories in each cookbook, and have some concepts about how cookbooks work.
* `recipes`: this folder contains actual commands to be executed to the remote server. To make the recipe as dynamic as possible, you can utilize ruby style programming language and include variables from:
  * attributes folder in each cookbooks
  * nodes
  * roles
  
which same variable name has the following priority (from high to low): `nodes` -> `roles` -> `attributes`. Well, it is actually much more complicated, but for basic usages, this knowledge is sufficient. 
recipes are usually named `default.rb`, and referenced by nodes and roles by `”recipe[cookbook_name]"`. If you happen to give different name, you can reference it by writing `”recipe[cookbook_name::recipe_name]"`.
* `attributes`: this folder contains `default.rb`, which contains variables that is used by the recipe to generate dynamic recipes. you define it by `default[‘key’] = value` - a ruby-style hash, and you can reference it in recipes by writing `node[‘key’]`.
* `templates/default`: this folder contains file templates that you want to dynamically generate with variables by passing the values from recipes. If you want to statically generate files, use `files/default` folder instead.

Variables can also be defined in your nodes and roles json file, and can be referenced by using `node[‘key’]`. (actually environments can also do that, but I skip that since I don’t know what that folder is actually about).

The recipe itself deserves a special mention. It uses ruby’s special syntax (ruby Domain Specific Language - DSL). Most of the commands are written using that Ruby DSL, and you can mix them with ruby syntax to make it flexible. there is A TON of (confusing) definitions you can use out there. For the complete list, open [Site Map — Chef Docs](https://docs.chef.io/), look at the left menu, click chef -> cookbook reference -> resources.

### .gitignore
all files which contains variables (`nodes/my_ip_address.json`, all files in attributes folder) is igonred (i.e. not pushed to the repository), but there is an example so you can know what variables you need to provision the server properly based on this script, and provide the values based on your needs.

## Capistrano
When you want to have a server running your code, what you do is:
1. store the code in a repository (e.g. github)
2. connect into your remote server
3. copy (clone) the code into your server
4. execute required commands/additional tasks to run the app (e.g. run app server, manage databases, etc).

Basically, capistrano does all that for you, if you configure it properly.

### Installation
Prerequisites: Ruby, bundler
Steps: put this in your `Gemfile`:
```ruby
group :development do
  gem "capistrano", "~> 3.9"
end
```
then run `bundle install --path=vendor/bundle`.
Capistrano alone is… pretty useless. so, you would want to add more capistrano-related gems to run tool specific tasks while deploying. for example, if you want to deploy a rails applicaton then you should add `gem ‘capistrano-rails’, ‘~>1.3’` to run rails tasks while deploying with capistrano.

Just google `capistrano {tool_name}` to search for gems for running that `{tool_name}`’s task with capistrano. I’m using `rails` (web framework), `rbenv` (ruby version manager), `puma` (ruby app server), and `bundler` (ruby package manager), so I added `capistrano-rails`, `capistrano-rbenv`, `capistrano3-puma`, and `capistrano-bundler` in my gemfile.

### Settings
Run `bundle exec cap install`, then some files and directories will be created:

#### Capfile
File to manage dependencies, to run tasks or commands needed to deploy the code. It:
  * lists all dependencies (tools) that you want to use when deploying - `require {tools_name}`
  * installs the enabled dependencies’ tools (if needed) - `install_plugin {Tool::Class}`
  * load custom tasks (if you have any defined) - `Dir.glob(“/dir/to/task”).each{|r| import r}`

#### lib/capistrano/tasks
Place to write rake tasks (and be included in capfile and be executed in deployment if you want to).

#### config/deploy.rb
Basic configuration for the code you want to deploy:
  * application name
  * the repository’s URL you want the code to be deployed
  * which branch of that repository’s URL
  * remote server’s target directory - `/path/to/dir/`. If the deployment is successful, the actual code will be deployed in `/path/to/dir/current/`.
  * and other settings.
  
Two properties that deserves a special mention:
  * `linked_files`: list of files that will be symlinked (windows language: shortcut) to the actual file in your shared directory (`/path/to/dir/shared/symlinked_file`)
  * `linked_dirs`: same as `linked_files` but for directories.
  
This way, files included in `linked_files` and `linked_dirs` will always be included across deployments, since every deployment will create shortcuts to the actual files at the shared directory.
Example: `linked_files “.env.production"` means that in your deployment directory `/path/to/dir/current` there will be a shortcut `.env.production` that points to the actual file (`/path/to/dir/shared/.env.production`).

#### config/deploy/{environment}.rb
Basic configuration for your target server, like.. where to deploy, the environment of the deployment, which SSH key you want to use to connect to the target server, and so on

There’s actually a role settings, but I don’t know how to utilize that, so I’m gonna skip that for now.

## References
### Chef
knife-solo: [knife-solo](https://matschaffer.github.io/knife-solo/)
example of how to write cookbooks by yourself: [Provisioning a Rails Server Using Chef, Part 1: Introduction to Chef Solo](http://vladigleba.com/blog/2014/07/28/provisioning-a-rails-server-using-chef-part-1-introduction-to-chef-solo/)
chef resources: [About Resources — Chef Docs](https://docs.chef.io/resource.html)
cookbook directories: [Cookbook Directory Structure](http://www.thegeekstuff.com/2016/06/chef-cookbook-directory-structure/)

### Capistrano
capistrano github: [GitHub - capistrano/capistrano: Remote multi-server automation tool](https://github.com/capistrano/capistrano)
capistrano puma github: [GitHub - seuros/capistrano-puma: Puma integration for Capistrano](https://github.com/seuros/capistrano-puma)
example: [Deploy your code with Capistrano  •  Beanstalk Guides](http://guides.beanstalkapp.com/deployments/deploy-with-capistrano.html)