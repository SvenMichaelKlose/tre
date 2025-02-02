tré Lisp compiler
=================

tré compiles a Common Lisp-inspired dialect of the Lisp programming language
to either JS, PHP or Common Lisp to build itself to run on top of [Steel Bank
Common Lisp](https://sbcl.org).  It brings the power of Lisp to the cheapest
of web servers.  Mostly LAMP ones.  tré does not just provide a funny syntax
required to unleash the super-powers of Lisp macro expansion.  It is a
compiler, perfectly able to generate C, bytecode and assembly with only few
extra lines of code.

After a Corona break, tré's development is being continued alongside
[TUNIX Lisp](https://github.com/SvenMichaelKlose/tunix/) for small systems.
The focus is on **integrating JSON data**, a new kind of **Object Relation Mapper**
to get around the pains of SQL database programming, a **unified object system**,
a completed **Lisp Markup Language** implementation, and **type inference**.

Within 18 months computational power doubles in general.  What once took tré
ten minutes to compile now takes ten seconds, so tré is not designed for raging
performance.  tré is a micro-pass compiler that is rather easy to maintain but
still could use a lot of cleaning up.  Feel free to join to make it simpler.

Please be aware that debugging generated JS and PHP code can be a major pain in
the backplate.  A PHP debugger setup is highly recommended unless you're
made to debug with wits exclusively.  Developers who are into _Test Driven
Development_ though should be pretty comfortable and also find value in tré.

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

tré requires SBCL and Git.  You require basic knowledge of Common LISP, PHP and
JavaScript.

To install the required packages on Ubuntu or derivates run:

~~~sh
sudo apt install sbcl git -y
~~~

## Running 'make.sh'

Shell script "make.sh" is the makefile for tre with several actions you can
list by specifying target "help".

~~~sh
./make.sh help
~~~

To build and install just do:

~~~sh
./make.sh boot
./make.sh install
~~~

This will build and install executable "tre" to /usr/local/bin/ and all other
files to /usr/local/.  TODO: environment var "PREFIX" to change the destination
directory.  It takes an optional pathname of a source file to compile and
execute.  If no file was specified, it'll prompt you for expressions to
execute.

## VIM syntax file

While booting the environment tré generates a syntax file for VIM named
'tre.vim' which you can copy to ~/.vim/after/syntax/.  It extends the already
existing syntax highlighting rules for Lisp code by everything that's been
defined in environment/.
