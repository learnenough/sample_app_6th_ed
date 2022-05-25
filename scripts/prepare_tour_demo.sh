#!/usr/bin/env bash

set -ex

git checkout HEAD Gemfile Gemfile.lock appmap.yml
rm -f ~/.appmaprc
rm appmap.yml
cat scripts/remove_appmap_gem.patch | git apply
