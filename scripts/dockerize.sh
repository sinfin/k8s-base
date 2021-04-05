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
git add kubernetes docker Dockerfile* prepare_test.sh docker-compose.yml .gitlab-ci.yml
git add scripts Gemfile
git commit -m "Dockerize application"
git push -u origin dockerize
repo=$(git remote get-url origin | cut -d: -f2- | sed 's/.git$//')
open https://github.com/${repo}/pull/new/dockerize
