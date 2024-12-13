#!/bin/sh

set -e

mkdir -p compiled/data
cp -r docker docker-compose.yml compiled/
tre make.lisp
