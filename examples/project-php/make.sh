#!/bin/sh

set -e

mkdir -p compiled/data/mysql
cp -r docker docker-compose.yml db-config.php compiled/
tre make.lisp
