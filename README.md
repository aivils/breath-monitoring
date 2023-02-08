# Breath monitoring

This project is intended for remote measurement of the client's respiratory process. An Android mobile phone or Windows Desktop PC that is equipped with a video camera can be used as a measuring device. The webmaster grants access to the client. The customer logs in to the web page and can start the measurement process according to the instructions. The customer can take measurements independently. The therapist can view the client's independent measurements in the admin panel. If the client and the therapist agree on a joint measurement time, the therapist can observe the client's measurement in real time.



* Ruby version

- 2.6.5

The system often does not have this version of ruby. So the easiest way to install the required version of ruby is to install Ruby Version Manager.
https://rvm.io/rvm/install

- 2.7.7

```
rvm pkg install openssl
rvm install 2.7.7  --with-openssl-dir=$HOME/.rvm/usr --autolibs=0
```

* Ruby on Rails

- 6.0.2.2

* System dependencies

- MySQL
- Node.js

* Configuration

```
bundle install
```

* Database creation

## Ubuntu 22 LTS

```
apt install mariadb-server
apt install libmariadb-dev
```

```
rake db:create
rake db:migrate
```

```
CREATE USER 'rdeveloper'@'localhost' IDENTIFIED BY 'rdeveloper';
CREATE DATABASE breath_development;
GRANT ALL PRIVILEGES ON breath_development.* TO 'rdeveloper'@'localhost';
```

* Database initialization

```
rake db:seed
```

* Deployment instructions

Edit file
```
config/deploy/production.rb
```

```
cap production deploy
```

* Start localhost

```
bundle exec rails s
```

## Admin user

```
$ bundle exec rails c
Loading development environment (Rails 6.0.6.1)
2.7.7 :001 > role = Role.find_by(name: "Admin")
2.7.7 :001 > user = User.create(email: 'admin@a.lv', role_ids: [role.id], password: '12345678', password_confirmation: '12345678')
```

