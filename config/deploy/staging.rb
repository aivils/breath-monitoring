set :stage, :staging
set :branch, :master

set :deploy_to, "/home/rails/#{fetch(:stage)}"
set :user, 'rails'

role :app, %w{13.233.133.8}
role :web, %w{13.233.133.8}
role :db,  %w{13.233.133.8}

server '13.233.133.8',
  user: 'rails',
  roles: %w{web app}

