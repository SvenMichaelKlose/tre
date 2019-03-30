#!/bin/sh

mkdir tre_modules
for i in l10n sql-clause php php-db-mysql php-http-request session; do \
    git clone --depth 1 http://github.com/SvenMichaelKlose/tre-$i.git tre_modules/$i; \
done
