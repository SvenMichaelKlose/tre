tré Lisp compiler
=================

tré compiles a Common Lisp-inspired dialect of the Lisp programming language
to either JS, PHP or Common Lisp to build itself to run on top of [Steel Bank
Common Lisp](https://sbcl.org).  It brings the power of Lisp to the cheapest
of web servers.  Mostly LAMP ones.  tré does not just provide a funny syntax
required to unleash the super-powers of Lisp macro expansion.  It is a
compiler, perfectly able to generate C, bytecode and assembly with only few
extra lines of code.

tré's development is taking place alongside the
[TUNIX Lisp](https://github.com/SvenMichaelKlose/tunix/) compiler for small
systems.

# Roadmap

The focus now is on **integrating JSON data**, a new kind of **Object Relation
Mapper** like
[PHP Object Relation Mapper (PORM)](https://github.com/SvenMichaelKlose/PORM/)
to get around the pains of SQL database programming, a **unified object system**,
a completed **Lisp Markup Language** implementation, and **type inference**.

# Documentation

2. [Build and install](#build-and-install)
3. [FAQ – Frequently Asked Questions](doc/FAQ.md)
1. [Contributors](CONTRIB.md)
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

# Build and install

tré needs packages 'sbcl' and 'git', available on every modern unixoid.
To build and install just do:

~~~sh
./make.sh reset image install
~~~

This will build and install executable "tre" to /usr/local/bin/ and all other
files to /usr/local/.  TODO: environment var "PREFIX" to change the destination
directory.  It takes an optional pathname of a source file to compile and
execute.  If no file was specified, it'll prompt you for expressions to
execute.

If you're curious about other actions run:

~~~sh
./make.sh help
~~~

## VIM syntax file

While booting the environment tré generates a syntax file for VIM named
'tre.vim' which you can copy to ~/.vim/after/syntax/.  It extends the already
existing syntax highlighting rules for Lisp code by everything that's been
defined in environment/.
