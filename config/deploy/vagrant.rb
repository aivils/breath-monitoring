set :stage, :staging
set :branch, :master

set :deploy_to, "/home/rails/#{fetch(:stage)}"
set :user, 'rails'

role :app, %w{10.0.2.2}
role :web, %w{10.0.2.2}
role :db,  %w{10.0.2.2}

server '10.0.2.2',
  user: 'rails',
  roles: %w{web app},
  ssh_options: {
    port: 2001,
  }
