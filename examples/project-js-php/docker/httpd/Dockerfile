FROM php:7.3-apache
RUN apt update
RUN apt full-upgrade -y
RUN docker-php-ext-install mysqli
COPY php.ini /usr/local/etc/php/
RUN a2enmod rewrite
WORKDIR /var/www/html
