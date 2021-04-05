# Dockerize application

## Prerequisites

* prepared `.env.sample` for tests
* configuration via environment variables (all stages)

## Usage

```
curl https://raw.githubusercontent.com/sinfin/k8s-base/master/scripts/dockerize.sh | bash -
```

## How it works?

1. download latest release of dockerize package
2. unpack the package
3. create new branch called `dockerize`
4. push the new branch
5. open browser with PR

## What will happend?

1. creates dockerfiles
    * `Dockerfile.base` - ruby + system packages
    * `Dockerfile.packages` - base + Gemfile packages
    * `Dockerfile` - packages + application
2. k8s configuration in `kubernetes/<env>/*`
   * review - adhoc environment for MR/PR reviews (manual action), contains redis and database
   * staging - stable staging environement before production deployment (manual action), contains redis and database
   * production - production deployment
3. `docker-compose.yml` - run complete stack in docker
4. `.gitlab-ci.yml` - Gitlab pipeline definition

## What next?

1. update all dockerfiles for project
2. update `config.yaml` files for staging and review
3. update `backend.yml` and `sidekiq.yml` container limits in all `kubernetes/*` environments
4. update `Gemfile` for dependencies like `redis-namespace`, `status-page`, ...
5. remove capistrano from project
6. review and merge PR
7. run seed on each environment manualy
