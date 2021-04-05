#!/bin/bash

wget https://github.com/sinfin/k8s-base/tarball/master -O k8s-base.tar.gz
tar xvzf k8s-base.tar.gz && \
	rm -f k8s-base.tar.gz && \
	mv sinfin-k8s-base*/* sinfin-k8s-base*/.gitlab-ci.yml . && \
	rmdir sinfin-k8s-base*
git checkout -b dockerize
git checkout README.md
cat << EOF >> Gemfile

gem "sidekiq-monitoring", "1.3.4"
gem "status-page", "0.1.5"
EOF
project=$(git remote get-url origin | cut -d: -f2- | sed 's/.git$//' | cut -d/ -f2)
cat << EOF > config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5

development:
  <<: *default
  username: <%= ENV['DB_USER'] || 'postgres' %>
  password: <%= ENV['DB_PASSWORD'] || '' %>
  host: <%= ENV['DB_HOST'] || 'localhost' %>
  port: <%= ENV['DB_PORT'] || 5432 %>
  database: <%= ENV['DB_NAME'] || '${project}_development' %>

test:
  <<: *default
  username: <%= ENV['TEST_DB_USER'] || ENV['DB_USER'] || 'postgres' %>
  password: <%= ENV['DB_PASSWORD'] || ENV['DB_PASSWORD'] || '' %>
  host: <%= ENV['TEST_DB_HOST'] || ENV['DB_HOST'] || 'localhost' %>
  port: <%= ENV['TEST_DB_PORT'] || ENV['DB_PORT'] || 5432 %>
  database: <%= ENV['TEST_DB_NAME'] || ENV['DB_NAME'] || '${project}_test' %>

staging:
  username: <%= ENV['DB_USER'] %>
  password: <%= ENV['DB_PASSWORD'] %>
  adapter: postgresql
  host: <%= ENV['DB_HOST'] %>
  port: <%= ENV['DB_PORT'] %>
  database: <%= ENV['DB_NAME'] %>
  encoding: utf8
  collation: cs_CZ.UTF8
  min_messages: warning
  pool: <%= ENV['DB_POOL'] %>
  timeout: 3000

production:
  username: <%= ENV['DB_USER'] %>
  password: <%= ENV['DB_PASSWORD'] %>
  adapter: postgresql
  host: <%= ENV['DB_HOST'] %>
  port: <%= ENV['DB_PORT'] %>
  database: <%= ENV['DB_NAME'] %>
  encoding: utf8
  collation: cs_CZ.UTF8
  min_messages: warning
  pool: <%= ENV['DB_POOL'] %>
  timeout: 3000
EOF

cat << EOF > config/cable.yml
development:
  adapter: async

test:
  adapter: test

staging:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
  channel_prefix: <%= ENV.fetch("REDIS_NAMESPACE") { "default" } %>

production:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
  channel_prefix: aukceaukci_production
EOF
git add kubernetes docker Dockerfile* prepare_test.sh docker-compose.yml .gitlab-ci.yml
git add scripts Gemfile config/database.yml config/cable.yml
git commit -m "Dockerize application"
git push -u origin dockerize
repo=$(git remote get-url origin | cut -d: -f2- | sed 's/.git$//')
open https://github.com/${repo}/pull/new/dockerize
