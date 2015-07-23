# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'teamplanner'
set :deploy_user, 'deployer'

set :scm, :git
set :repo_url, 'git@github.com:fattah/TeamPlanner.git'

set :rbenv_type, :system
set :rbenv_ruby, '2.1.1'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

set :keep_releases, 5
set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :tests, []

set(:config_files, %w(
  nginx.conf
  database.example.yml
  log_rotation
))

set(:symlinks, [
                 {
                     source: "nginx.conf",
                     link: "/etc/nginx/sites-enabled/#{fetch(:full_app_name)}"
                 },
                 {
                     source: "log_rotation",
                     link: "/etc/logrotate.d/#{fetch(:full_app_name)}"
                 }
             ])


# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  before :deploy, "deploy:check_revision"
  before :deploy, "deploy:run_tests"
  after 'deploy:symlink:shared', 'deploy:compile_assets_locally'
  after :finishing, 'deploy:cleanup'
  before 'deploy:setup_config', 'nginx:remove_default_vhost'
  after 'deploy:setup_config', 'nginx:reload'
  after 'deploy:publishing', 'deploy:restart'

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
