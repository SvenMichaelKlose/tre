#!/bin/sh
# tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

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
BUILDOPTS="-O2 -march=native -mtune=native"
CRUNSHOPTS="-O2 --whole-program -march=native -mtune=native"
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

basic_clean ()
{
	echo "Cleaning..."
	rm -vf *.core interpreter/$COMPILED_ENV tre image bytecode-image tmp.c __alien.tmp files.lisp compilation.log
    rm -rf environment/_current-version environment/transpiler/targets/c64/tre.c64
	rm -vrf obj
    rm -vf examples/js/hello-world.js
}

distclean ()
{
	echo "Cleaning for distribution..."
    basic_clean
	rm -rf backup compiled
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
	$CC $CFLAGS $COPTS -o $TRE $CRUNSHTMP $LIBFLAGS || exit 1
	rm $CRUNSHTMP
}

install_it ()
{
	sudo cp -v $TRE $BINDIR || exit 1
    cp -v image ~/.tre.image || exit 1
}

case $1 in
crunsh)
	CFLAGS="$CFLAGS $CRUNSHFLAGS"
	COPTS="$COPTS $CRUNSHOPTS"
	crunsh_compile
	;;

reload)
    echo "Reloading environment from source..."
    svnversion -n >environment/_current-version
    echo | ./tre -n
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
	;;

build)
    echo "Making regular build file by file..."
	COPTS="$COPTS $BUILDOPTS"
	standard_compile
	link
	;;

precompile)
    echo "Precompiling target core functions..."
	echo "(precompile-environments)(dump-system \"image\")" | ./tre || exit 1
	;;


compiler)
    echo "Compiling the compiler only..."
	(echo "(compile-c-compiler)(dump-system \"image\")" | ./tre -i image) || exit 1
    ;;

bcompiler)
    echo "Compiling the bytecode compiler only..."
	(echo "(compile-c-environment '(compile-bytecode-environment))" | ./tre) || exit 1
	./make.sh crunsh $ARGS || exit 1
    ;;

environment)
    echo "Compiling environment..."
	(echo "(compile-c-environment)(dump-system \"image\")" | ./tre -i image | tee compilation.log) || exit 1
	;;

boot)
    echo "Booting everything from scratch..."
	./make.sh interpreter $ARGS || exit 1
	./make.sh compiler $ARGS || exit 1
	./make.sh crunsh $ARGS || exit 1
	./make.sh environment $ARGS || exit 1
	./make.sh crunsh $ARGS|| exit 1
	;;

test)
    echo "Making tests..."
	./make.sh interpreter $ARGS || exit 1
	./make.sh compiler $ARGS || exit 1
	./make.sh environment $ARGS || exit 1
	./make.sh crunsh || exit 1
	./make.sh install || exit 1
    tre makefiles/test-php.lisp
    tre makefiles/test-js.lisp
	;;

debugboot)
    echo "Booting everything from scratch..."
	./make.sh interpreter $ARGS || exit 1
	./make.sh compiler $ARGS || exit 1
	./make.sh environment $ARGS || exit 1
	./make.sh debug || exit 1
	./make.sh reload || exit 1
	;;

bytecode)
    echo "Making bytecodes for everything..."
	(echo "(load-bytecode (compile-bytecode-environment))(dump-system \"image\")" | ./tre) || exit 1
	;;

bytecode-image)
    echo "Making bytecodes for everything..."
	(echo "(with-output-file o \"bytecode-image\" (adolist ((compile-bytecode-environment)) (late-print ! o)))" | ./tre) || exit 1
	;;

all)
    echo "Making all..."
	./make.sh boot $ARGS || exit 1
	./make.sh install || exit 1
    tre makefiles/filelist.lisp || exit 1
    tre makefiles/test-php.lisp || exit 1
    tre makefiles/test-js.lisp || exit 1
    tre makefiles/webconsole.lisp || exit 1
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
    cp -v tre backup
    cp -v interpreter/_compiled-env.c backup
    cp -v image backup
    echo "Backed up to backup/. Use 'restore' on occasion."
    ;;

restore)
    sudo cp backup/tre $BINDIR
    cp -v backup/tre .
    cp -v backup/_compiled-env.c interpreter
    cp -v backup/image .
    ;;

*)
	echo "Usage: make.sh boot|interpreter|compiler|all|bytecode|debug|build|crunsh|reload|precompile|backup|restore|install|clean|distclean [args]"
	echo "  boot            Build everything from scratch."
	echo "  test            Build everything from scratch in stealth mode."
	echo "  debugboot       Like 'boot', but for debugging"
	echo "  interpreter     Clean and build the interpreter."
	echo "  compiler        Compile just the compiler and the C target to C."
	echo "  bcompiler       Compile just the compiler and the bytecode target to bytecode."
    echo "  environment     Compile environment to C."
    echo "  bytecode        Compile environment to bytecode, replacing the C functions."
    echo "  bytecode-image  Compile environment to bytecode image."
    echo "  all             Compile everything makefiles/ has to offer."
    echo "  build           Do a regular build file by file."
    echo "  debug           Compile C sources for gdb. May the force be with you."
    echo "  crunsh          Compile C sources as one big file for best optimization."
    echo "  reload          Reload the environment."
    echo "  backup          Backup installation to local directory 'backup'."
    echo "  restore         Restore the last 'backup'."
    echo "  install         Install the compiled executable."
    echo "  clean           Remove built files but not the backup."
    echo "  distclean       Like 'clean' but also removes backups."
    echo "  precompile      Precompile obligatory target environments (EXPERIMENTAL)."
    ;;
esac
