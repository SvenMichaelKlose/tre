The tré programming language
============================

tré transpiles a streamlined dialect of Lisp to JavaScript, PHP7
and Common Lisp (the latter mainly to compile itself).

# Build and install

## Prerequisites

tré requires SBCL and Git.  You require basic knowledge of
Common LISP, PHP and JavaScript.

To install the required packages on Ubuntu or derivates run:

~~~sh
sudo apt install sbcl git -y
~~~

## Build and install

Shell script "make.sh" is the makefile for tre with several
actions you can list by specifying target "help".

~~~sh
./make.sh help
~~~

To build and install just do:

~~~sh
./make.sh boot
./make.sh install
~~~

This will build and install executable "tre" to
/usr/local/bin/ and all other files to /usr/local/.
TODO: environment var "PREFIX" to change the destination
directory.  It takes an optional pathname of a source file to
compile and execute.  If no file was specified, it'll prompt
you for expressions to execute.

## History

tré started as a Lisp interpreter written in C in 2005 and makes
JS and PHP code since 2008.  2013 is has been moved to Steel Bank
Common Lisp.  That's why you might find eerie code in some places.

## VIM syntax file

While booting the environment tré generates a syntax file for VIM named
'tre.vim' which you can copy to ~/.vim/after/syntax/.  It extends the
already existing syntax highlighting rules for Lisp code.

# Starting a project

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

# Syntax

tré comes with a lot of syntactical sugar to keep things snappy.

## No LAMBDA symbol required

The LAMBDA symbol may be omitted when defining functions.
(Influenced by Arc.)

```lisp
; Old style.
#'(lambda (args)
    function-body)

; tré style.
#'((args)
    function-body)
```

## Dots instead of CAR or CDR

Probably inspired by some COBOL manual, tré takes
the edge off by removing the zoo of CAR, CDR and related
expressions.  Instead of doing "(car x)" you are now invited to
use "x." instead.  The equivalent for "(cdr x)" would be ".x".
You can also combine the two dots, so "(cadr x)" is ".x." for the
second element.  To access the third element "(caddr x)" just do
"..x.".

```lisp
x.      ; (car x)
.x      ; (cdr x)
.x.     ; (cadr x)
..x.    ; (caddr x)
..x..   ; (caaddr x)
```

It does not work around parentheses yet.

## Dot instead of CONS

```lisp
; Old style.
(cons a b)

; tré style.
(. a b)
```

## Brackets '[]' for anonymous functions

Inspired by Arc

```lisp
[expr]

[(expr1)
 (expr2)]
```

is the equivalent of

```lisp
#'((_)
    (expr))

#'((_)
    (expr1)
    (expr2))
```

If 'expr' starts with a symbol, it is wrapped into a list to
form an expression.

PROPOSAL!  NOT IMPLEMENTED YET:
Tré also lets you make your own argument definitions.  To roll
your own basically end them with a closing parenthesis:

```lisp
[body]              #'((_) body)
[) body]            #'(() body)
[x) body]           #'((x) body)
[x &rest y) body]   #'((x rest y) body)
```

## Braces '{}' to make JSON objects

If you open an expression with a curly brace it'll become a
JSON object.

```lisp
{
  "item2"  "2" ; It's highly recommended to use strings!
  :item1   "1"
  :oh-no   3   ; Will be converted to camel notation and result in "ohNo".
}
```

## General abbreviations

Inspired by the C syntax these are synonyms for what you
would otherwise expect from Common Lisp.  The original names
are, most of the time, still there.

* == instead of =
* = instead of SETF
* ? instead of IF
* & instead of AND
* | instead of OR
* / instead of DIV

Due to name collision the original meaning of '=' is gone
in favour of '=='.

There are also abbreviations for some anaphoric macros
inspired by Arc (which are there as well):

* != instead of ALET (Arc)
* !? instead of AIF (Arc)
* !@ instead of ADOLIST (Arc) (See also '@'.)


## @ instead of DOLIST or FILTER

Also warks with arrays.

```lisp
; Use as FILTER.
(@ #'filter-function x)
```

```lisp
; Use as DOLIST.
(@ (i x)
  (filter-function/return-value-lost i))
```

## +@ instead of MAPCAN

Only works for lists.

## BACKQUOTE for anonymous macros

These are QUASIQUOTEs aka commas outside BACKQUOTEs aka backticks
aka '`'.  They are evaluated before the standard macro expansion
pass.

```lisp
(progn
  ,@(generate-some-code-expressions))
```

## PROPOSAL: Comma for dynamic SLOT-VALUE access (NOT IMPLEMENTED)

When working with JSON data for example lots of SLOT-VALUE
expressions can spoil the fun.  Here's an example:

```lisp
(slot-value slot name)  ; Old style.
slot.,name              ; New style.
```

# Porting from PHP to tré

## Literal constants

Use %%NATIVE to inject native source strings:
```lisp
(some_php_function (%%native "LITERAL_CONSTANT_NAME_WITHOUT_DOLLAR"))
```

### Modules

TODO: This section should describe how directory 'modules' can be
utilised.

## Examples

### [JavaScript 3D canvas](https://github.com/SvenMichaelKlose/tre-example-js-canvas3d)

Software-rendered 3D, playing a video on a rotating plane.
