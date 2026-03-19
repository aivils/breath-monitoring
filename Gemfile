source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.9'

gem 'rails', '~> 7.2', '>= 7.2.3'
gem 'mysql2'
gem 'puma', '~> 6.4'
gem 'sass-rails', '>= 6'
#gem 'webpacker', '~> 4.0'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'haml-rails', '~> 2.0'
gem 'devise'
gem 'devise-jwt'
gem 'pundit'
gem 'activeadmin', '>= 3.2'
gem 'redis'
gem 'recaptcha'
gem 'dotenv-rails'
gem 'kaminari'

gem 'foreman', '0.90.0', require: false

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capistrano', '~> 3.6', require: false
  gem 'capistrano-bundler', '~> 1.6', require: false
  gem 'capistrano-rvm', '~> 0.1', require: false
  gem "capistrano-rails", "~> 1.5", require: false

  gem 'rspec-rails', '~> 6.1'
  gem 'factory_bot_rails'
  gem 'rswag-specs'
  gem 'rswag-api'
  gem 'rswag-ui'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen'
  gem 'spring', '~> 4.1'
  gem 'byebug'
end

group :test do
  gem 'database_cleaner-active_record'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "dockerfile-rails", ">= 1.5", :group => :development
