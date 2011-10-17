#!/bin/sh
# tré programming language
# Build script
# Copyright (c) 2005-2011 Sven Klose <pixel@copei.de>

svnversion -n >_current-version

ARGS="$2 $3 $4 $5 $6 $7 $8 $9"

FILES="
    alien_dl.c
    alloc.c
    argument.c
    array.c
    atom.c

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
LIBC_PATH=`find /lib -name libc.so.* | head -n 1`
LIBDL_PATH=`find /lib -name libdl.so.* | head -n 1`
KERNEL_IDENT=`uname -i`
SYSTEM_NAME=`uname -n`
CPU_TYPE=`uname -m`
OS_RELEASE=`uname -r`
OS_VERSION="unknown" #`uname -v`
BUILD_MACHINE_INFO="-DBIG_ENDIAN -DLIBC_PATH=\"$LIBC_PATH\" -DTRE_KERNEL_IDENT=\"$KERNEL_IDENT\" -DTRE_SYSTEM_NAME=\"$SYSTEM_NAME\" -DTRE_CPU_TYPE=\"$CPU_TYPE\" -DTRE_OS_RELEASE=\"$OS_RELEASE\" -DTRE_OS_VERSION=\"$OS_VERSION\""

GNU_LIBC_FLAGS="-D_GNU_SOURCE -D_BSD_SOURCE -D_SVID_SOURCE"
C_DIALECT_FLAGS="-ansi -Wall " #-Werror"

CFLAGS="-pipe $C_DIALECT_FLAGS $GNU_LIBC_FLAGS $BUILD_MACHINE_INFO $ARGS"

DEBUGOPTS="-O0 -g"
BUILDOPTS="-O"
CRUNSHOPTS="-Ofast --whole-program"
CRUNSHFLAGS="-DTRE_COMPILED_CRUNSHED -Iinterpreter"

LIBFLAGS="-lm -lffi"

if [ -f /lib/x86_64-linux-gnu/libdl.so* ]; then
	LIBFLAGS="$LIBFLAGS -ldl";
fi

if [ -f interpreter/_compiled-env.c ]; then
	FILES="$FILES _compiled-env.c";
	CFLAGS="$CFLAGS -DTRE_HAVE_COMPILED_ENV";
fi

CRUNSHTMP="tmp.c"
TRE="./tre"
BINDIR="/usr/local/bin/"

echo "libc is '$LIBC_PATH'."
echo "libdl is '$LIBDL_PATH'."
echo "Compiler: $CC"
echo "Compiler flags: $CFLAGS $COPTS"
echo "Library flags: $LIBFLAGS"

basic_clean ()
{
	echo "Cleaning..."
	rm -f *.core interpreter/_compiled-env.c
	rm -rf obj
}

link ()
{
	echo "Linking..."
	OBJS=`find obj -name \*.o`
	$LD -o tre $OBJS $LIBFLAGS
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
	$CC $CFLAGS -fwhole-program $COPTS -o $TRE $CRUNSHTMP $LIBFLAGS
	rm $CRUNSHTMP
}

install_it ()
{
	echo "Initialising default environment."
	echo | $TRE -n
	echo "Installing $TRE to $BINDIR."
	sudo cp $TRE $BINDIR
}

install_it_without_reload ()
{
	echo "Installing $TRE to $BINDIR."
	sudo cp $TRE $BINDIR
}

case $1 in
debug)
	COPTS="$COPTS $DEBUGOPTS"
	standard_compile
	link
	install_it
	;;

debugraw)
	COPTS="$COPTS $DEBUGOPTS"
	standard_compile
	link
	install_it_without_reload
	;;

build)
	COPTS="$COPTS $BUILDOPTS"
	standard_compile
	link
	install_it
	;;

crunsh)
	CFLAGS="$CFLAGS $CRUNSHFLAGS"
	COPTS="$COPTS $CRUNSHOPTS"
	crunsh_compile
	install_it
	;;

boot0)
	CFLAGS="$CFLAGS $CRUNSHFLAGS"
	COPTS="$COPTS $CRUNSHOPTS"
	crunsh_compile
	;;

crunshraw)
	CFLAGS="$CFLAGS $CRUNSHFLAGS"
	COPTS="$COPTS $CRUNSHOPTS"
	crunsh_compile
	install_it_without_reload
	;;

boot)
	basic_clean
	./make.sh crunsh $ARGS
	./tre makefiles/make-compiled1.lisp
	./make.sh crunshraw $ARGS
	./tre makefiles/make-compiled.lisp
	./make.sh crunshraw $ARGS
	;;

bootunclean)
	./make.sh boot0
	./tre make-compiled.lisp
	./make.sh crunshraw
	;;

recompile)
	echo "(quit)" | tre -n
	tre makefiles/make-compiled.lisp
	./make.sh crunshraw
	;;

install)
	install_it_without_reload
	;;

clean)
	basic_clean
	;;

*)
	echo "Usage: make.sh build|clean|crunsh|debug [args]"
esac
