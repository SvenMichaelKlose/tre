#!/bin/sh

mkdir tre_modules
for i in l10n lml sql-clause php php-db-mysql php-http-request js js-http-request http-funcall; do \
    git clone --depth 1 http://github.com/SvenMichaelKlose/tre-$i.git tre_modules/$i; \
done
