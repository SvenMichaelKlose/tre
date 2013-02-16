#!/bin/sh
# tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

svnversion -n >environment/_current-version

ARGS="$2 $3 $4 $5 $6 $7 $8 $9"

FILES="
    alien.c
    alloc.c
    apply.c
    argument.c
    array.c
    atom.c

	builtin.c
	builtin_arith.c
    builtin_array.c
    builtin_atom.c
	builtin_debug.c
	builtin_error.c
	builtin_fileio.c
	builtin_image.c
	builtin_list.c
	builtin_net.c
	builtin_number.c
	builtin_sequence.c
	builtin_stream.c
	builtin_string.c
	builtin_time.c

	bytecode.c
	cons.c
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
	queue.c
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
CPU_TYPE=`uname -m`
OS_RELEASE=`uname -r`
OS_VERSION="unknown" #`uname -v`
BUILD_MACHINE_INFO="-DTRE_BIG_ENDIAN -DLIBC_PATH=\"$LIBC_PATH\" -DTRE_KERNEL_IDENT=\"$KERNEL_IDENT\" -DTRE_CPU_TYPE=\"$CPU_TYPE\" -DTRE_OS_RELEASE=\"$OS_RELEASE\" -DTRE_OS_VERSION=\"$OS_VERSION\""

GNU_LIBC_FLAGS="-D_GNU_SOURCE -D_BSD_SOURCE -D_SVID_SOURCE"
C_DIALECT_FLAGS="-ansi -Wall -Wextra -Werror"

CFLAGS="-pipe $C_DIALECT_FLAGS $GNU_LIBC_FLAGS $BUILD_MACHINE_INFO $ARGS"

DEBUGOPTS="-O0 -g"
BUILDOPTS="-Ofast"
CRUNSHOPTS="-Ofast --whole-program"
CRUNSHFLAGS="-DTRE_COMPILED_CRUNSHED -Iinterpreter"

LIBFLAGS="-lm -lffi -ldl -lrt"

if [ -f /lib/x86_64-linux-gnu/libdl.so* ]; then
	LIBFLAGS="$LIBFLAGS -ldl";
fi

COMPILED_ENV=${COMPILED_ENV:-"_compiled-env.c"}

if [ -f interpreter/$COMPILED_ENV ]; then
	FILES="$FILES $COMPILED_ENV";
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
	rm -f *.core interpreter/$COMPILED_ENV tre tmp.c __alien.tmp environemnt/_current-version
	rm -rf obj
    rm -f examples/js/hello-world.js
}

distclean ()
{
	echo "Cleaning for distribution..."
    basic_clean
	rm -rf backup
}

link ()
{
	echo "Linking..."
	OBJS=`find obj -name \*.o`
	$LD -o $TRE $OBJS $LIBFLAGS || exit 1
}

standard_compile ()
{
	mkdir -p obj
	for f in $FILES; do
		echo "Compiling $f"
		$CC $CFLAGS $COPTS -c -o obj/$f.o interpreter/$f || exit 1
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
	$CC $CFLAGS -fwhole-program $COPTS -o $TRE $CRUNSHTMP $LIBFLAGS || exit 1
	rm $CRUNSHTMP
}

install_it ()
{
	echo "Initialising default environment."
	echo | $TRE -n
	echo "Installing $TRE to $BINDIR."
	sudo cp $TRE $BINDIR || exit 1
}

install_it_without_reload ()
{
	echo "Installing $TRE to $BINDIR."
	sudo cp $TRE $BINDIR || exit 1
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

precompile)
	echo "(precompile-environments)" | ./tre || exit 1
	;;

boot)
	basic_clean
	./make.sh crunsh $ARGS || exit 1
	(echo "(compile-bytecode-compiler)(dump-system)" | ./tre) || exit 1
	(echo "(compile-c-environment)" | ./tre) || exit 1
	./make.sh crunsh $ARGS || exit 1
	;;

bootunclean)
	./make.sh boot0 || exit 1
	(echo "(compile-c-environment)" | ./tre) || exit 1
	./make.sh crunshraw || exit 1
	;;

recompile)
	echo "(quit)" | tre -n
	(echo "(compile-c-environment)" | ./tre) || exit 1
	./make.sh crunshraw || exit 1
	;;

bytecode)
	(echo "(compile-bytecode-environment)(dump-system)" | ./tre) || exit 1
	;;

install)
	install_it_without_reload
	;;

clean)
	basic_clean
	;;

distclean)
	distclean
	;;

backup)
    mkdir backup
    cp tre backup
    cp interpreter/_compiled-env.c backup
    cp ~/.tre.image backup
    echo "Backed up to backup/. Use 'restore' on occasion."
    ;;

restore)
    sudo cp backup/tre /usr/local/bin/
    cp backup/tre .
    cp backup/_compiled-env.c interpreter
    cp backup/.tre.image ~
    ;;

*)
	echo "Usage: make.sh boot|bootunclean|build|crunsh|crunshraw|recompile|debug|debugraw|backup|restore|install|clean [args]"
esac
