The tré programming language
============================

tré compiles Lisp to browser JavaScript and PHP to bring the joy
of Lisp development to web-site programming.  tré also somes with
a bunch of syntacical novelties that lets Lisp appear in a new
light.

tré is not just remapping its input. It's a "real" compiler, fit
to support compiling to C, for example, so it also brings Lisp
features to PHP 5+ – you can use code for both targets.


# Build and install

tré requires some Linux with "sbcl" (Steel Bank Common Lisp)
installed.  But to get real kicks out of tré, you'd need "git"
and "docker-compose", too. On an Debia-derived distributions,
like "Ubuntu" or "Linux Mint"

```sh
sudo apt install git sbcl docker-compose -y
```

should do.  You won't need to have a web server installed.

Then run:

```sh
./make.sh boot
./make.sh install
```

This will install an executable called "tre" in /usr/local/bin.
It takes an optional pathname of a source file to compile and
execute.  If none is specified, it'll prompt you for
expressions to execute.  We won't to that too often, though.
Now let's get started.


# Starting a project

Let's get ready to hack.  There're three initial projects
prepared for you in directory example/ which you can copy to
take off.  All contain configurations for docker-compose to run
your project in a virtual LAMP server.  "project-js" for making a
plain JavaScript app,  "project-php" to create a PHP-only
challenge and "project-js-php" to make an app that'll communicate
with it's PHP server – by function calls wrapped in HTTP requests.

## Creating a JavaScript-only project

Can't wait? Copy examples/project-js to a directory of your own
naming and step into it:

```sh
cp examples/project-js <someplace-new>
cd <someplace-new>
```sh

Then install the required modules;

```sh
./install-modules.sh
```

Now compile the example code:

```sh
./make.sh
```

Step into directory compiled and start the docker container:

```sh
cd compiled
sudo docker-compose up
```

This may take a while and download several hundred megabytes to
setup its very own Linux distribution the first time you do this.
Now point your browser at http://localhost:19020/ – voilà!

## Creating a PHP-only project

This works the same as creating a JavaScript-only project, except
that you have to copy examples/project-php.

But this time the docker container also has a MySQL database
installed.  Within the container it's listening on hostname "db"
from the outside you can read it at IP 0.0.0.0.  It's got two
users, "root" and "tre", both with password "secret".  You can
change these in file "docker-compose.yml" before doing your
first web server launch.  You can also remove the whole database
section from that file, if you won't need it.  A database
configuration has already been prepared for use with module
"php-db-mysql".

If you want to see a full-blown PHP-only example in action, please
visit https://github.com/SvenMichaelKlose/phitamine-shop.

## Creating a JavaScript project with PHP server and function calls via HTTP

Again, this works like "project-js".  This time the server
implements function SERVER-APPLY which takes a function name(!)
and its arguments – the JavaScript client basically asks the PHP
server to add 1 and 2 with function "+" and returns the result by
just calling SERVER-APPLY as if it was a JavaScript function.
This example also contains the MySQL database code and
configuration.


# Developing a project – here's the catch

The initial project setups come with a bunch of external modules 
included already, so you can play around with them without needing
to tweak the makefiles.  That's as simple as it can get at this
time.  tré comes with no IDE whatsoever.  But what you'll see in
your browser's debugger is more or less readable.  Some

```lisp
(invoke-debugger)
(console.log "%o" buggyobject)
```

in considerate places might help out a lot, as well as PRINT and
LOG-MESSAGE on the PHP side.  If you decide to continue working
with tré you WILL find inconveniences and bugs.  And that's the
point where you hopefully contribute by filing bugs and ask
questions on github.com or even contribute own code.  Yep.  It's
a great time to become a key part of the tré programming language
project, with fame and honour and so on.


# Syntax

tré comes with a lot of syntactical sugar to get rid of those
embarrassing braces and to keep things snappy.

## No LAMBDA symbol required

The LAMBDA symbol may be safely omitted when defining functions.
Influenced by Arc.

```lisp
 #'(lambda (args)
     function-body)
```
can be written:

```lisp
 #'((args)
     function-body)
```

## General abbreviations

Inspired by the C syntax these are synonyms for what you
would expect from Common Lisp.  The original names are,
most of the time, still there.

* == instead of =
* = instead of SETF
* ? instead of IF
* & instead of AND
* | instead of OR
* / instead of DIV

Due to name collision the original meaning of '=' is gone
in favour of '=='.

There are also abbreviations for some anaphoric macros
inspired by Arc (which are still around):

* != instead of ALET (Arc)
* !? instead of AIF (Arc)
* !@ instead of ADOLIST (Arc) (See also '@'.)

## Dot instead of CONS

```lisp
(. a b)
```

is the same as

```lisp
(cons a b)
```

## Dots instead of CAR or CDR

Probably inspired by some COBOL manual, tré first of all takes
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

## Brackets for anonymous functions

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

NOT IMPLEMENTED YET:
Tré also lets you make your own argument definitions.  To roll
your own basically end them with a closing parenthesis:

```lisp
[body]              #'((_) body)
[) body]            #'(() body)
[x) body]           #'((x) body)
[x &rest y) body]   #'((x rest y) body)
```

## Braces to make JSON objects or instead of PROGN

If you open an expression with a curly brace it'll become a
literal (JSON) object if the first element is a keyword or a
string.  Then the argument is grouped into key/value pairs.
Otherwise it'll become a PROGN.

```lisp
; Use as PROGN (first element is not a string or keyword).
(| x
   {(do-something)
    (do-something-else)}

; Use as literal object.
{:item1    "1"
 "item2"   "2"
 :oh-no    3}
```

Note that keyword keys will be translated into camel notation.
':oh-no' will become 'ohNo'.

## At sign @ instead of DOLIST or FILTER

```lisp
; Use as FILTER.
(@ #'filter-function x)
```

```lisp
(@ (i x)
  (filter-function/return-value-lost i))
```

## Comma for anonymous macros

These are QUASIQUOTEs aka commas outside BACKQUOTEs aka backticks
aka '`'.  They are evaluated before the standard macro expansion
pass.

```lisp
Some exciting example missing here.
```

## Comma for dynamic SLOT-VALUE access (NOT IMPLEMENTED)

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

## External resources

### Applications

### [phitamine demo shop](https://github.com/SvenMichaelKlose/phitamine-shop)

### Examples

### [phitamine](https://github.com/SvenMichaelKlose/phitamine)

A framework to create PHP-only web sites with tré.
[centralservices](https://github.com/SvenMichaelKlose/centralservices)
provides a couple of widgets.

### [bender](https://github.com/SvenMichaelKlose/bender)

A UNIX command line 6502-CPU assembler.

### Modules

[JavaScript DOM and utilities](https://github.com/SvenMichaelKlose/tre-js)

[Localisation](https://github.com/SvenMichaelKlose/tre-l10n)

[PHP utilities](https://github.com/SvenMichaelKlose/tre-php)

[PHP MySQL interface](https://github.com/SvenMichaelKlose/tre-php-db-mysql)

[Utilities shared across platforms](https://github.com/SvenMichaelKlose/tre-shared)

[SQL clause generators](https://github.com/SvenMichaelKlose/tre-sql-clause)

[Lisp Markup Language utilities](https://github.com/SvenMichaelKlose/tre-lml)

[Multitrack timetable + JS DOM graphics](https://github.com/SvenMichaelKlose/tre-timetable)

## Examples

### [JavaScript 3D canvas](https://github.com/SvenMichaelKlose/tre-example-js-canvas3d)

Software-rendered 3D, playing a video on a rotating plane.
