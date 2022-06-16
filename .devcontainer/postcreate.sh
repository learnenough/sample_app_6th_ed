rvm install "ruby-3.0.2"
rvm use 3.0.2
bundle install
yarn install
bundle exec rails webpacker:install
bundle exec rails webpacker:compile
bundle exec rails db:migrate