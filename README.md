The tré programming language
============================

tré transpiles its dialect of Lisp to JavaScript, PHP7+ and
Common Lisp (the latter mainly to compile itself).

# Build and install

tré requires some Linux with "sbcl" (Steel Bank Common Lisp)
installed.

On a Debia-derived distributions,
like "Ubuntu" or "Linux Mint"

```sh
sudo apt install sbcl -y
```

should do.

Then run:

```sh
./make.sh boot
./make.sh install
```

This will install an executable called "tre" in /usr/local/bin.
It takes an optional pathname of a source file to compile and
execute.  If none is specified, it'll prompt you for
expressions to execute.

## VIM syntax file

During boot tré generates a syntax file for VIM named 'tre.vim'
which you can copy to ~/.vim/after/syntax/.  It extends the
already existing syntax highlighting rules for Lisp code.

# Starting a project

Let's get ready to hack.  There're three initial projects
prepared for you in directory examples/ which you should copy to
take off as they are subject to getting cleaned thoroughly.  All
contain configurations for docker-compose to run your project in
a virtual LAMP server.  "project-js" for making a plain JavaScript
app,  "project-php" to create a PHP-only challenge and
"project-js-php" to make a JS app that'll communicate with it's PHP
server.

## Creating a JavaScript-only project

Can't wait? Copy examples/project-js to a directory of your own
naming and step into it:

```sh
mkdir new-js-project
cp /usr/local/share/tre/examples/project-js new-js-project
```sh

Now compile the example code:

```sh
cd new-js-project
./make.sh
```

Step into directory 'compiled' and start the docker container:

```sh
cd compiled
sudo docker-compose up
```

Now point your browser at http://localhost:19020/ – voilà!

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


## Developing a project – here's the catch

The initial project setups come with a bunch of external modules 
included already, so you can play around with them without need
to tweak the makefiles.  That's as simple as it can get at this
time.  tré comes with no IDE whatsoever.
If you decide to continue working with tré you WILL find
inconveniences and bugs – and you are very welcome to help out.

## How to debug tré programs

What you'll see in your browser's debugger is more or less
readable.  One of

```lisp
(invoke-debugger)
```
or one of
```lisp
(console.log "%o" buggyobject)
(dump my-object)
(dump my-object "My object")
```

in considerate places might help out a lot, as well as PRINT and
the DUMP function on the PHP side.

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
literal (JSON) object if the first element is a keyword or a
string.  Then the argument is grouped into key/value pairs.
Otherwise it'll become a PROGN.

```lisp
; Use as PROGN (first element is not a string or keyword).
(| x
   {(do-something)
    (do-something-else)}

; Use as literal object.
{"item2"   "2"  ; It's highly recommended to use strings!
 :item1    "1"
 :oh-no    3}   ; Will be converted to camel notation and
                ; result in "ohNo".
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
