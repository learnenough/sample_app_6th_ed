#!/usr/bin/env bash

set -ex

rm ~/.appmaprc
rm appmap.yml
cat scripts/remove_appmap_gem.patch | git apply || true
