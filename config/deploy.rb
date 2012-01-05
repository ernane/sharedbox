# RVM bootstrap
#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
#require 'rvm/capistrano'
#set :rvm_ruby_string, '1.9.2-p290'

# bundler bootstrap
#require 'bundler/capistrano'

set :application, "sharedbox"
set :ip_address , "173.246.40.14"

# repo details
set :scm, :git
set :repository,  "git@github.com:ernane/sharedbox.git"
set :branch, "master"
set :deploy_via, :remote_cache

# SSH SETTINGS
set :user , "ernane"
set :deploy_to, "/home/ernane/rails_apps/#{application}"
set :shared_directory, "#{deploy_to}/shared"
set :use_sudo, false
set :group_writable, false
default_run_options[:pty] = true

role :app, ip_address
role :web, ip_address
role :db,  ip_address, :primary => true

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

# tasks
namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  task :trust_rvmrc do
      run "rvm rvmrc trust #{latest_release}"
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Symlink extra configs and folders."
  task :symlink_extras do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/initializers/mail_settings.rb #{release_path}/config/initializers/mail_settings.rb"
  end

  desc "Setup shared directory."
  task :setup_shared do
    run "mkdir #{shared_path}/config/initializers"
    run "mkdir #{shared_path}/config"
    puts "Now edit the config files and fill assets folder in #{shared_path}."
  end
end


after "deploy", "deploy:cleanup" # keeps only last 5 releases
after "deploy:setup", "deploy:setup_shared"
after "deploy:update_code", "deploy:symlink_extras"


