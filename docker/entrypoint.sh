#!/bin/bash

PROCESS=${PROCESS:-$1}

case $PROCESS in
  development)
      cd /app/ && \
        bundle install --jobs $( nproc ) && \
        bundle exec rake db:migrate && \
        bundle exec rake assets:precompile && \
        mkdir -p /app//log && \
        bundle exec puma -C /app/config/puma.rb
  ;;
  assets:precompile)
      cd /app/ && \
        bundle exec rake assets:precompile
  ;;
  db:migrate)
      cd /app/ && \
        bundle exec rake db:migrate
  ;;
  db:seed)
      cd /app/ && \
        bundle exec rake db:seed
  ;;
  db:seed:sleep)
      cd /app/ && \
      sleep 180 && \
      bundle exec rake db:seed
  ;;
  app:cron)
      cd /app/ && \
      bundle exec rake $CRON_TASK
  ;;
  server:sidekiq)
      cd /app/ && \
        bundle exec sidekiq -C /app/config/sidekiq.yml -P /app/tmp/pids/sidekiq.pid
  ;;
  server:puma)
      cd /app/ && \
        bundle exec rake db:migrate && \
        bundle exec puma -C /app//config/puma.rb
  ;;
  server:nginx)
      nginx -g 'daemon off;'
  ;;
  *)
      exec "$@"
  ;;
esac
