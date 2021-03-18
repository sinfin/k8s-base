#!/bin/bash

wget https://github.com/sinfin/k8s-base/tarball/master -O k8s-base.tar.gz
tar xvzf k8s-base.tar.gz && \
	rm -f k8s-base.tar.gz && \
	mv sinfin-k8s-base*/* sinfin-k8s-base*/.gitlab-ci.yml . && \
	rmdir sinfin-k8s-base*
git checkout -b dockerize
git checkout README.md
git add kubernetes docker Dockerfile* prepare_test.sh docker-compose.yml .gitlab-ci.yml
git commit -m "Dockerize application"
git push -u origin dockerize
repo=$(git remote get-url origin | cut -d: -f2- | sed 's/.git$//')
open https://github.com/${repo}/pull/new/dockerize
