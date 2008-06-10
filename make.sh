#!/bin/sh

ARGS="$2 $3 $4 $5 $6 $7 $8 $9"

BOOT_IMAGE=`echo ~/.tre.image`
FILES="alien_dl.c alloc.c argument.c array.c atom.c builtin.c builtin_arith.c
	builtin_array.c builtin_atom.c builtin_debug.c builtin_fileio.c builtin_image.c
	builtin_list.c builtin_number.c builtin_stream.c builtin_string.c
	debug.c diag.c
	error.c env.c eval.c gc.c image.c io.c io_std.c list.c macro.c main.c number.c
	print.c read.c sequence.c special.c stream.c string.c symbol.c thread.c util.c"

CC=cc
LD=cc

LIBC_PATH=`find /lib -name libc.so\*`

CFLAGS="-pipe -ansi -Wall -DBIG_ENDIAN -DLIBC_PATH=\"$LIBC_PATH\" -DTRE_BOOT_IMAGE=\"$BOOT_IMAGE\" $ARGS"

CRUNSHTMP="tmp.c"
TRE="tre"
BINDIR="/usr/local/bin/"

echo "libc is at '$LIBC_PATH'."

basic_clean ()
{
	echo "Cleaning..."
	rm -f *.core
	rm -rf obj
}

link ()
{
	echo "Linking..."
	OBJS=`find obj -name \*.o`
	$LD -lm -lthr -o tre $OBJS
}

standard_compile ()
{
	mkdir -p obj
	for f in $FILES; do
		echo "Compiling $f"
		$CC $CFLAGS $COPTS -c -o obj/$f.o interpreter/$f
	done
}

crunsh_compile ()
{
	rm -f $CRUNSHTMP
	for f in $FILES; do
		echo "Collecting $f"
		cat interpreter/$f >>$CRUNSHTMP
	done
	echo "Compiling crunshed for best optimisation..."
	$CC $CFLAGS $COPTS -o $TRE $CRUNSHTMP
	rm $CRUNSHTMP
}

install_it ()
{
	echo "Installing $TRE to $BINDIR."
	sudo cp $TRE $BINDIR
}

case $1 in
debug)
	COPTS="$COPTS -O0 -g"
	basic_clean
	standard_compile
	link
	install_it
	;;
build)
	COPTS="$COPTS -O2 -fomit-frame-pointer -ffast-math"
	basic_clean
	standard_compile
	link
	install_it
	;;
crunsh)
	CFLAGS="$CFLAGS -DCRUNSHED -Iinterpreter"
	COPTS="$COPTS -O3 -march=pentium3m -fomit-frame-pointer -ffast-math -fwhole-program -lm -lthr "
	basic_clean
	crunsh_compile
	install_it
	;;
clean)
	basic_clean
	;;
*)
	echo "Usage: make.sh build|clean|crunsh|debug [args]"
esac

