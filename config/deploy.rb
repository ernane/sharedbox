# RVM bootstrap
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.2-p290'

# bundler bootstrap
require 'bundler/capistrano'

# main details
set :application, "sharedbox"
set :ip_address , "173.246.40.14"
role :app, ip_address
role :web, ip_address
role :db,  ip_address, :primary => true

# server details
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :deploy_to, "/home/ernane/rails_apps/#{application}"
set :deploy_via, :remote_cache
set :user, "ernane"
set :use_sudo, false

# repo details
set :scm, :git
set :repository,  "git@github.com:ernane/sharedbox.git"
set :branch, "master"
set :deploy_via, :remote_cache

# tasks
namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Symlink extra configs and folders."
  task :symlink_extras do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/initializers/mail_setting.rb #{release_path}/config/initializers/mail_setting.rb"
  end

  desc "Setup shared directory."
  task :setup_shared do
    run "mkdir #{shared_path}/config/initializers"
    run "mkdir #{shared_path}/config"
    puts "Now edit the config files and fill assets folder in #{shared_path}."
  end
end

before "deploy", "deploy:check_revision"
after "deploy", "deploy:cleanup" # keeps only last 5 releases
after "deploy:setup", "deploy:setup_shared"
after "deploy:update_code", "deploy:symlink_extras"