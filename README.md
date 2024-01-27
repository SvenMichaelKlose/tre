The tré programming language
============================

tré transpiles a streamlined dialect of Lisp to JavaScript, PHP7
and Common Lisp (the latter mainly to compile itself).

# Table of Contents

1. [Build and install](#build-and-install)
2. [Introduction to Lisp](doc/intro-to-lisp.md)
3. [Starting a Project](doc/starting-a-project.md)
4. [Syntax](doc/syntax.md)
5. [Class](doc/class.md)
6. [Porting from PHP](doc/porting-from-php.md)
7. [Compiler](doc/compiler.md)
8. [Stuff using tré](doc/stuff-using-tré.md)

<a id="build-and-install"></a>
# Build and install

## Prerequisites

tré requires SBCL and Git.  You require basic knowledge of
Common LISP, PHP and JavaScript.

To install the required packages on Ubuntu or derivates run:

~~~sh
sudo apt install sbcl git -y
~~~

## Running 'make.sh'

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
