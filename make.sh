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
	builtin_function.c
	builtin_image.c
	builtin_list.c
	builtin_net.c
	builtin_number.c
	builtin_sequence.c
	builtin_stream.c
	builtin_string.c
	builtin_symbol.c
	builtin_time.c

	bytecode.c
	cons.c
	debug.c
	dot.c
	error.c
	eval.c
	function.c
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

LIBC_PATH=`find /lib -name libc.so.* | head -n 1`
LIBDL_PATH=`find /lib -name libdl.so.* | head -n 1`
KERNEL_IDENT=`uname -i`
CPU_TYPE=`uname -m`
OS_RELEASE=`uname -r`
OS_VERSION="unknown" #`uname -v`
BUILD_MACHINE_INFO="-DTRE_BIG_ENDIAN -DLIBC_PATH=\"$LIBC_PATH\" -DTRE_KERNEL_IDENT=\"$KERNEL_IDENT\" -DTRE_CPU_TYPE=\"$CPU_TYPE\" -DTRE_OS_RELEASE=\"$OS_RELEASE\" -DTRE_OS_VERSION=\"$OS_VERSION\""

GNU_LIBC_FLAGS="-D_GNU_SOURCE -D_BSD_SOURCE -D_SVID_SOURCE"
C_DIALECT_FLAGS="-ansi -Wall -Wextra"

CFLAGS="-pipe $C_DIALECT_FLAGS $GNU_LIBC_FLAGS $BUILD_MACHINE_INFO $ARGS"

DEBUGOPTS="-O0 -g"
BUILDOPTS="-Ofast --whole-program -flto -march=native -mtune=native"
CRUNSHOPTS="-Ofast --whole-program -flto -march=native -mtune=native"
CRUNSHFLAGS="-DTRE_COMPILED_CRUNSHED -Iinterpreter"

LIBFLAGS="-lm -lffi -ldl -lrt -flto"

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
	echo "Compiling as one file for best optimisation..."
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
	echo "Installing $TRE to $BINDIR."
	sudo cp $TRE $BINDIR || exit 1
}

case $1 in
crunsh)
	CFLAGS="$CFLAGS $CRUNSHFLAGS"
	COPTS="$COPTS $CRUNSHOPTS"
	crunsh_compile
	install_it
	;;

reload)
    echo "Reloading environment from source..."
    echo | tre -n
	;;

interpreter)
    echo "Making interpreter..."
	basic_clean
	./make.sh crunsh $ARGS || exit 1
	./make.sh reload $ARGS || exit 1
	;;

debug)
    echo "Making debuggable version..."
	COPTS="$COPTS $DEBUGOPTS"
	standard_compile
	link
	install_it
	;;

build)
    echo "Making regular build file by file..."
	COPTS="$COPTS $BUILDOPTS"
	standard_compile
	link
	install_it
	;;

precompile)
    echo "Precompiling target core functions..."
	echo "(precompile-environments)" | ./tre || exit 1
	;;


compiler)
    echo "Making just the compiler..."
	(echo "(compile-c-compiler)" | ./tre) || exit 1
	./make.sh crunsh $ARGS || exit 1
    ;;

all)
    echo "Making everything..."
	(echo "(compile-c-environment)" | ./tre) || exit 1
	./make.sh crunsh || exit 1
	;;

boot)
    echo "Booting everything from scratch..."
	./make.sh interpreter $ARGS || exit 1
	./make.sh compiler $ARGS || exit 1
	./make.sh all $ARGS || exit 1
	;;

bytecode)
    echo "Making bytecodes for everything..."
	(echo "(load-bytecode (compile-bytecode-environment))(dump-system)" | ./tre) || exit 1
	;;

install)
	install_it
	;;

clean)
	basic_clean
	;;

distclean)
	distclean
	;;

backup)
    echo "Making backup..."
    mkdir -p backup
    cp -v $BINDIR/tre backup
    cp -v interpreter/_compiled-env.c backup
    cp -v ~/.tre.image backup/image
    echo "Backed up to backup/. Use 'restore' on occasion."
    ;;

restore)
    sudo cp backup/tre $BINDIR
    cp -v backup/tre .
    cp -v backup/_compiled-env.c interpreter
    cp -v backup/image ~/.tre.image
    ;;

*)
	echo "Usage: make.sh boot|interpreter|compiler|all|bytecode|debug|build|crunsh|reload|precompile|backup|restore|install|clean|distclean [args]"
	echo "  boot         Build everything from scratch."
	echo "  interpreter  Clean and build the interpreter."
	echo "  compiler     Compile just the compiler, not the whole environment."
    echo "  all          Compile environment."
    echo "  bytecode     Compile environment to bytecode, replacing the C functions."
    echo "  build        Do a regular C source build file by file."
    echo "  debug        Compile C sources for gdb. May the force be with you."
    echo "  crunsh       Compile C sources as one big file for best optimization."
    echo "  reload       Reload the environment."
    echo "  precompile   Precompile obligatory target environments (EXPERIMENTAL)."
    echo "  backup       Backup installation to local directory 'backup'."
    echo "  restore      Restore the last 'backup'."
    echo "  install      Install the compiled executable."
    echo "  clean        Remove executable, object files and garbage."
    echo "  distclean    Like 'clean' but also removing the last 'backup'."
    ;;
esac
