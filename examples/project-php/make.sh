#!/bin/sh

set -e

mkdir -p compiled/data
cp -r docker docker-compose.yml db-config.php compiled/
tre make.lisp
