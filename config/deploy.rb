# config valid for current version and patch releases of Capistrano
lock "~> 3.17.0"
set :rvm_ruby_version, '2.7.7'

set :application, "breath_mon"
set :repo_url, "file:///home/rails/repo/"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/database.yml", "config/master.key", "config/credentials/production.key", ".env.production"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache" #, "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 2

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :foreman do
  desc "Export the Procfile to Ubuntu's systemd scripts"
  task :export do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :sudo, "/usr/local/rvm/bin/rvm #{fetch(:rvm_ruby_version)} do bundle exec foreman export systemd /etc/systemd/system " +
        "-f Procfile.#{fetch(:stage)} -a #{fetch(:application)}-#{fetch(:stage)} -u #{fetch(:user)} -l #{shared_path}/log -e ./foreman.env.#{fetch(:stage)} --root #{current_path}"
        end
      end
    end
  end

  desc 'Start the application services'
  task :start do
    on roles(:app) do
      execute :sudo, "/bin/systemctl start #{fetch(:application)}-#{fetch(:stage)}.target"
    end
  end

  desc 'Stop the application services'
  task :stop do
    on roles(:app) do
      execute :sudo, "/bin/systemctl stop #{fetch(:application)}-#{fetch(:stage)}.target"
    end
  end

  desc 'Restart the application services'
  task :restart do
    on roles(:app) do
      execute :sudo, "/bin/systemctl restart #{fetch(:application)}-#{fetch(:stage)}.target"
    end
  end
end

# full app restart
after  'deploy:finished', 'foreman:restart'

