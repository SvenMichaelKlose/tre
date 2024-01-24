# Starting a Project

Let's get ready to hack!  There're three initial projects
prepared for you in directory examples/ which you should copy to
take off as they are subject to getting cleaned thoroughly.  All
contain configurations for docker-compose to run your project in
a virtual LAMP server.  "project-js" for making a plain Java-
Script app,  "project-php" to create a PHP-only challenge and
"project-js-php" to make a JS app that'll communicate with it's
PHP server.

## Creating a JavaScript-only project

Can't wait? Copy examples/project-js to a directory of your own
naming and step into it:

```sh
mkdir new-js-project
cp -r /usr/local/share/tre/examples/project-js new-js-project
```sh

Now compile the example code:

```sh
cd new-js-project
./make.sh
```

It should create file 'compiled/index.html'.

### Running with PHP on the command-line

Step into directory 'compiled' and start the docker container:

```sh
php -S localhost:19020
```

Now point your browser at http://localhost:19020/ – voilà!

### Running with docker-compose

This will also run a MySQL server alongside Apache and PHP.
Step into directory 'compiled' and start the docker container:

```sh
cd compiled
sudo docker-compose up
```

This may take while to do the first time if docker needs to
download images.

## Creating a PHP-only project

This works the same as creating a JavaScript-only project, except
that you have to copy examples/project-php.

But this time the docker container also has a MySQL database
installed.  Within the container it's listening on hostname "db".
From the outside you can access it via IP 0.0.0.0.  It's got two
users, "root" and "tre", both with password "secret".  You can
change these in file "docker-compose.yml" before doing your
first web server launch.  You can also remove the whole database
section from that file, if you won't need it.

## Creating a JavaScript project with PHP server and function calls via HTTP

Again, this works like "project-js".  This time the server
implements function SERVER-APPLY which takes a function name(!)
and its arguments – the JavaScript client basically asks the PHP
server to add 1 and 2 with function "+" and returns the result by
just calling SERVER-APPLY as if it was a JavaScript function.
This example also contains the MySQL database code and
configuration.

## Debugging functions

```lisp
(invoke-debugger)
```
or one of

```lisp
(console.log "%o" buggyobject)
(dump my-object)
(dump my-object "My object title")
```
