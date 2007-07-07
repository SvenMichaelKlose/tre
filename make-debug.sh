#!/bin/sh

ARGS="$1 $2 $3 $4 $5 $6 $7 $8 $9"

BOOT_IMAGE=`echo ~/.nix-lisp.image`

compile() {
	local TMP
	TMP="gcc -DLISP_BOOT_IMAGE=\"$BOOT_IMAGE\" $ARGS -O0 -pipe -g -Wall -ansi -c -DLISP_VERBOSE_LOAD -o $1.o $1"
	echo $TMP
	$TMP
}

rm lisp.core
cd interpreter
rm *.o
compile alien_dl.c
compile alloc.c
compile argument.c
compile array.c
compile atom.c
compile builtin.c
compile builtin_arith.c
compile builtin_array.c
compile builtin_atom.c
compile builtin_debug.c
compile builtin_fileio.c
compile builtin_image.c
compile builtin_list.c
compile builtin_number.c
compile builtin_stream.c
compile builtin_string.c
compile debug.c
compile diag.c
compile error.c
compile env.c
compile eval.c
compile gc.c
compile image.c
compile io.c
compile io_std.c
compile list.c
compile macro.c
compile main.c
compile number.c
compile print.c
compile read.c
compile sequence.c
compile special.c
compile stream.c
compile string.c
compile symbol.c
compile thread.c
compile util.c

OBJS=`find . -name \*.o`
gcc -g -lm -o ../lisp $OBJS
rm $OBJS
