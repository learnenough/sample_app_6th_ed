bundle install
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt-get -y update
sudo apt-get -y install redis python2 graphviz
yarn install --check-files
bundle exec rails webpacker:install
bundle exec rails webpacker:compile
bundle exec rails db:migrate