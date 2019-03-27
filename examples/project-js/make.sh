#!/bin/sh

set -e

mkdir -p compiled
cp -r docker docker-compose.yml compiled/
tre make.lisp
