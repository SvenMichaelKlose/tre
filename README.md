The tré programming language
============================

tré compiles a cross-compatible dialect of Lisp to JavaScript, PHP 7+ and
Common Lisp.

# Table of Contents

1. [Contributors](CONTRIB.md)
2. [Build and install](#build-and-install)
3. [FAQ – Frequently Asked Questions](doc/FAQ.md)
4. [Introduction to Lisp](doc/intro-to-lisp.md)
5. [Starting a Project](doc/starting-a-project.md)
6. [Syntax](doc/syntax.md)
7. [Class](doc/class.md)
8. [Porting from PHP](doc/porting-from-php.md)
9. [Compiler](doc/compiler.md)
10. [Compiler source docs](environment/transpiler/README.md)
11. [Environment](environment/README.md)
12. [Modules](modules/README.md)
13. [Stuff using tré](doc/stuff-using-tré.md)
14. [Wishlist](WISHLIST.md)

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

## VIM syntax file

While booting the environment tré generates a syntax file for VIM named
'tre.vim' which you can copy to ~/.vim/after/syntax/.  It extends the
already existing syntax highlighting rules for Lisp code.
