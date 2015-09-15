# config valid only for current version of Capistrano
lock '3.4.0'

# require "rvm/capistrano"
set :rvm_ruby_version, '1.9.3-p551'
set :use_sudo, true

set :deploy_via, :checkout
set :application, 'aparcame'
set :repo_url, # CHANGE REPO URL
set :user, # CHANGE SSH USER

set :default_stage, "staging"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, # CHANGE DEPLOY TO
set :bundle_flags, "--no_deployment"

# ask(:svn_password, nil, echo: false)

# Default value for :scm is :git
set :scm, :svn

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  task :update_shared_symlinks do
    on roles(:app) do
      %w(config/database.yml config/environments/development.rb).each do |path|
        execute "rm -f #{File.join(release_path, path)}"
        #run "ln -s #{File.join(deploy_to, "shared", path)} #{File.join(release_path, path)}"
        execute "cp --link -r #{File.join(deploy_to, "shared", path)} #{File.join(release_path, path)}"
      end
    end

    on roles(:app) do
      %w(public/images).each do |path|
        execute "rm -rf #{File.join(release_path, path)}"
        execute "ln -nfs #{File.join(deploy_to, "shared", path)} #{File.join(release_path, path)}"
      end
    end

  end

  task :restart_server do
    on roles(:app) do
      sudo :chgrp, '-R www-data', release_path
      execute :touch, current_path.join("tmp/restart.txt")
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      execute :touch, current_path.join("tmp/restart.txt")
    end
  end

  before :migrate, :update_shared_symlinks do
  end

  after :finished, :restart_server do
  end
end
