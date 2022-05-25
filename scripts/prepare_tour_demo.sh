#!/usr/bin/env bash

set -ex

git checkout HEAD Gemfile Gemfile.lock appmap.yml

bundle
APPMAP=true DISABLE_SPRING=true bundle exec rake
yarn run openapi > swagger/openapi_stable.yaml

rm -f ~/.appmaprc
rm appmap.yml
cat scripts/remove_appmap_gem.patch | git apply
