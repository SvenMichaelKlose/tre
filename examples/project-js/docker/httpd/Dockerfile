FROM php:7.3-apache
COPY php.ini /usr/local/etc/php/
RUN a2enmod rewrite
RUN apt update
RUN apt full-upgrade -y
WORKDIR /var/www/html
