require 'rvm/capistrano'
require 'bundler/capistrano'
#require 'whenever/capistrano'

set :application, 'TeamPlanner'
set :repository, 'git@github.com:fattah/TeamPlanner.git'
set :scm, :git
# set :deploy_via, :remote_cache
set :rvm_ruby_string, '2.1.1'
set :rvm_type, :system
set :rake, 'bundle exec rake'
set :use_sudo, true
set :bundle_cmd, 'bundle'

# the user of the server which will run commands on server
default_run_options[:pty] = true
ssh_options[:port] = 22
ssh_options[:username] = 'deployer'
ssh_options[:host_key] = 'ssh-dss'
ssh_options[:paranoid] = false
ssh_options[:forward_agent] = true

task :link_shared_files, roles: :app do
  run "rm -rf #{current_path}/public/uploads; ln -s #{shared_path}/uploads #{current_path}/public/uploads"
end

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

task :production do
  set :user, 'deployer'
  set :branch, 'master'
  set :deploy_to, ''
  set :rails_env, 'production'
  web_server = ''
  set :application, web_server
  role :web, web_server # Your HTTP server, Apache/etc
  role :app, web_server # This may be the same as your `Web` server
  role :db, web_server, :primary => true # This is where Rails migrations will run
  set :keep_releases, 10
end

task :staging do
  set :branch, 'master'
  set :deploy_to, '/www/apps/teamplanner-staging'
  set :rails_env, 'staging'
  web_server = '106.186.115.31'
  set :application, web_server
  role :web, web_server # Your HTTP server, Apache/etc
  role :app, web_server # This may be the same as your `Web` server
  role :db, web_server, :primary => true # This is where Rails migrations will run
  set :keep_releases, 5
  #set :whenever_command, 'bundle exec whenever'
  #set :whenever_environment, defer { fetch(:rails_env) }
end

#If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end

  desc 'Restart the application'
  task :restart, roles: :app, :except => {:no_release => true} do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  task :create_shared_files_and_directories, role: :app do
    run "mkdir -p #{shared_path}/config/.bundle"
    run "mkdir -p #{shared_path}/bundle"
    run "touch #{shared_path}/config/.bundle/config"
    run "mkdir -p #{shared_path}/uploads"
    run "mkdir -p #{shared_path}/assets"
  end

  desc 'Copy the database.yml file into the latest release'
  task :copy_in_database_yml do
    run "cp #{shared_path}/config/database.yml #{latest_release}/config/"
    run "cp #{shared_path}/config/secrets.yml #{latest_release}/config/"
    run "cp #{shared_path}/config/superadmin.yml #{latest_release}/config/"
  end
end

before 'deploy:assets:precompile', 'deploy:copy_in_database_yml'
after 'deploy:setup', 'deploy:create_shared_files_and_directories'
after 'deploy:update_code', 'deploy:migrate'
after 'deploy:create_symlink', :link_shared_files
after 'deploy:update', 'deploy:cleanup'
