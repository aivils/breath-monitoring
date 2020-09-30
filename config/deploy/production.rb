set :stage, :production
set :branch, :master

set :deploy_to, "/home/rails/#{fetch(:stage)}"
set :user, 'rails'

role :app, %w{139.59.43.193}
role :web, %w{139.59.43.193}
role :db,  %w{139.59.43.193}

server '139.59.43.193',
  user: 'rails',
  roles: %w{web app}

