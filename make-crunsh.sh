#!/bin/sh

cd interpreter
cat *.c >_tmp.c
BOOT_IMAGE=`echo ~/.nix-lisp.image`
gcc -DCRUNSHED -DLISP_BOOT_IMAGE="\"$BOOT_IMAGE\"" -DLISP_VERBOSE_LOAD -fwhole-program -O3 -fomit-frame-pointer -ffast-math -lc -lm $1 $2 $3 $4 $5 $6 $7 $8 $9 -pipe -o ../lisp _tmp.c
rm _tmp.c
cd ..
strip lisp
