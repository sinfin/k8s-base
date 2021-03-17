ARG BASE=master
ARG CI_REGISTRY_IMAGE
FROM ${CI_REGISTRY_IMAGE}/packages:${BASE}

COPY . /app

ENV RAILS_ENV=production

RUN bundle exec rake assets:precompile

COPY docker/entrypoint.sh /
COPY docker/nginx.default.conf /etc/nginx/sites-enabled/default

ENTRYPOINT ["/entrypoint.sh"]
