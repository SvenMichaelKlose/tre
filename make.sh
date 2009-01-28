#!/bin/sh

echo "TRE programming language"
echo "Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>"

ARGS="$2 $3 $4 $5 $6 $7 $8 $9"

BOOT_IMAGE=`echo ~/.tre.image`
FILES="alien_dl.c alloc.c argument.c array.c atom.c

	builtin.c
	builtin_arith.c builtin_array.c builtin_atom.c
	builtin_debug.c
	builtin_error.c
	builtin_fileio.c
	builtin_image.c
	builtin_list.c
	builtin_number.c
	builtin_sequence.c
	builtin_stream.c
	builtin_string.c

	debug.c
	diag.c
	dot.c
	error.c
	env.c
	eval.c
	gc.c
	image.c
	io.c
	io_std.c
	list.c
	macro.c
	main.c
	number.c
	print.c
	quasiquote.c
	read.c
	special.c
	stream.c
	string.c
	symbol.c
	thread.c
	util.c"

CC=cc
LD=cc

echo
LIBC_PATH=`ls /lib/libc.so.*`
LIBDL_PATH=`ls /lib/libdl.so.*`
KERNEL_IDENT=`uname -i`
SYSTEM_NAME=`uname -n`
CPU_TYPE=`uname -m`
OS_RELEASE=`uname -r`
OS_VERSION="unknown" #`uname -v`
BUILD_MACHINE_INFO="-DBIG_ENDIAN -DLIBC_PATH=\"$LIBC_PATH\" -DTRE_KERNEL_IDENT=\"$KERNEL_IDENT\" -DTRE_SYSTEM_NAME=\"$SYSTEM_NAME\" -DTRE_CPU_TYPE=\"$CPU_TYPE\" -DTRE_OS_RELEASE=\"$OS_RELEASE\" -DTRE_OS_VERSION=\"$OS_VERSION\""

GNU_LIBC_FLAGS="-D_GNU_SOURCE -D_BSD_SOURCE -D_SVID_SOURCE"
C_DIALECT_FLAGS="-ansi -Wall -Werror"

CFLAGS="-pipe $C_DIALECT_FLAGS $GNU_LIBC_FLAGS $BUILD_MACHINE_INFO -DTRE_BOOT_IMAGE=\"$BOOT_IMAGE\" $ARGS"

LIBFLAGS="-lm"

if [ -f /lib/libdl.so* ]; then
	LIBFLAGS="$LIBFLAGS -ldl";
fi

CRUNSHTMP="tmp.c"
TRE="./tre"
BINDIR="/usr/local/bin/"

echo "libc is '$LIBC_PATH'."
echo "Compiler: $CC"
echo "Compiler flags: $CFLAGS $COPTS"
echo "Library flags: $LIBFLAGS"

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
	$LD $LIBFLAGS -o tre $OBJS
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
	echo "Compiling crunshed for best optimisation..."
	echo -n "Concatenating sources:"
	for f in $FILES; do
		echo -n " $f"
		cat interpreter/$f >>$CRUNSHTMP
	done
	echo
	echo "Compiling..."
	$CC $LIBFLAGS $CFLAGS $COPTS -o $TRE $CRUNSHTMP
	rm $CRUNSHTMP
}

install_it ()
{
	echo "Initialising default environment."
	echo | $TRE -n
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
	CFLAGS="$CFLAGS -DTRE_COMPILED_CRUNSHED -Iinterpreter"
	COPTS="$COPTS -O3 -fomit-frame-pointer -ffast-math -fwhole-program -lm"
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

