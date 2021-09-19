#!/bin/bash

wget https://github.com/sinfin/k8s-base/tarball/master -O k8s-base.tar.gz
tar xvzf k8s-base.tar.gz && \
	rm -f k8s-base.tar.gz && \
	mv sinfin-k8s-base*/* sinfin-k8s-base*/.gitlab-ci.yml . && \
	rmdir sinfin-k8s-base*
git checkout -b dockerize
git checkout README.md

cat << EOF >> Gemfile

# Sidekiq stuff
gem "sidekiq", "~> 5"
gem "sidekiq-cron", "1.2.0"
gem "redis-namespace", "1.8.1"
# Monitoring
gem "sidekiq-monitoring", "1.3.4"
gem "status-page", "0.1.5"
gem "rack-mini-profiler"
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
  password: <%= ENV['TEST_DB_PASSWORD'] || ENV['DB_PASSWORD'] || '' %>
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
  prepared_statements: false
  advisory_locks: false
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
  channel_prefix: ${project}_production
EOF

cat << EOF >> config/initializers/assets.rb
Rails.application.config.assets.configure do |env|
  env.export_concurrent = false
end
EOF

if [ ! -e config/sidekiq.yml ]; then
cat << EOF > config/sidekiq.yml
---
:concurrency: 5

production:
  :concurrency: 10

:queues:
  - [ ${project}_critical, 4 ]
  - [ ${project}_default, 2 ]
  - [ ${project}_ahoy, 1 ]
  - [ ${project}_mailers, 1 ]
  - [ ${project}_slow, 1 ]
EOF
fi

if [ ! -e config/initializers/active_job.rb ]; then
mkdir -p config/initializers/
cat << EOF > config/initializers/active_job.rb
# frozen_string_literal: true

if Rails.env.test?
  Rails.application.config.active_job.queue_adapter = :async
else
  if Rails.env.production? || Rails.env.staging? || (ENV["DEV_QUEUE_ADAPTER"] == "sidekiq" && ENV["REDIS_URL"])
    Rails.application.config.active_job.queue_adapter     = :sidekiq
    Rails.application.config.active_job.queue_name_prefix = "${project}"

    settings = {
      url: ENV["REDIS_URL"],
      namespace: ENV["REDIS_NAMESPACE"]
    }

    Sidekiq.configure_server do |config|
      config.redis = settings
    end

    Sidekiq.configure_client do |config|
      config.redis = settings
    end
  else
    Rails.application.config.active_job.queue_adapter = :async
  end
end
EOF
fi

if [ ! -e config/environments/staging.rb ]; then
  cp config/environments/production.rb config/environments/staging.rb
fi

git add k8s docker Dockerfile* prepare_test.sh docker-compose.yml .gitlab-ci.yml \
    scripts Gemfile config/database.yml config/cable.yml config/environments/staging.rb \
    config/initializers/active_job.rb config/sidekiq.yml

git commit -m "Dockerize application"
git push -u origin dockerize

repo=$(git remote get-url origin | cut -d: -f2- | sed 's/.git$//')
open https://github.com/${repo}/pull/new/dockerize
