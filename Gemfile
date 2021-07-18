source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'rails', '~> 6.0.2', '>= 6.0.4'
gem 'mysql2'
gem 'puma', '~> 4.3'
gem 'sass-rails', '>= 6'
#gem 'webpacker', '~> 4.0'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'haml-rails', '~> 2.0'
gem 'devise'
gem 'pundit'
gem 'activeadmin'
gem 'redis'
gem 'recaptcha'
gem 'dotenv-rails'

gem 'foreman', '0.87.1', require: false

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capistrano', '~> 3.6', require: false
  gem 'capistrano-bundler', '~> 1.6', require: false
  gem 'capistrano-rvm', '~> 0.1', require: false
  gem "capistrano-rails", "~> 1.5", require: false
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'byebug'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
