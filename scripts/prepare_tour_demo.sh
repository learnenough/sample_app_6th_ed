#!/usr/bin/env bash

set -ex

git checkout HEAD app test Gemfile Gemfile.lock appmap.yml swagger/openapi_stable.yaml
rm -f ~/.appmaprc
rm appmap.yml
cat scripts/remove_appmap_gem.patch | git apply
