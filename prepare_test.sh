#!/bin/bash

cp .env.sample .env
[ -f test/dummy/.env.sample ] && cp test/dummy/.env.sample test/dummy/.env
for f in config/*.example; do cp "$f" "${f/.example/}"; done
mkdir -p vendor/assets/redactor
touch vendor/assets/redactor/redactor.css
touch vendor/assets/redactor/redactor.js
