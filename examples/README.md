tré examples
============

These are the absolute minimum setups to get JS, PHP, or both, to run
on virtual LAMP containers using docker-compose.

~~~sh
cd project-js-php
./make.sh
cd compiled
sudo docker-compose up
~~~

Don't forget to bring it down again like so, or trying to bring it
up again will bring on confusing error messages:

~~~sh
sudo docker-compose down

; Also an option:
sudo docker-compose down --remove-orphans
~~~
