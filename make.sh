#!/bin/sh
# tré – Copyright (c) 2005–2016 Sven Michael Klose <pixel@hugbox.org>

set -e

ARGS="$2 $3 $4 $5 $6 $7 $8 $9"

FILES="
    alien.c
    alloc.c
    array.c
    atom.c
    backtrace.c

	builtin.c
	builtin_apply.c
	builtin_arith.c
    builtin_array.c
    builtin_atom.c
	builtin_error.c
	builtin_fs.c
	builtin_function.c
	builtin_list.c
	builtin_memory.c
	builtin_net.c
	builtin_number.c
	builtin_sequence.c
	builtin_stream.c
	builtin_string.c
	builtin_symbol.c
	builtin_terminal.c
	builtin_time.c

	bytecode.c
	cons.c
	error.c
	exception.c
	funcall.c
	function.c
	gc.c
	image.c
	linenoise.c
	list.c
	main.c
	number.c
	ptr.c
	queue.c
	special_exception.c
	stream.c
	stream_file.c
	stream_string.c
	string.c
	symtab.c
	symbol.c
	thread.c
	type.c
	util.c"

CC=gcc
LD=gcc

LIBC_PATH=`find /lib64 /lib/x86_64-linux-gnu/ /lib -name libc.so.* | head -n 1`
LIBDL_PATH=`find /lib64 /lib -name libdl.so.* | head -n 1`
KERNEL_IDENT=`uname -i`
CPU_TYPE=`uname -m`
OS_RELEASE=`uname -r`
OS_VERSION="unknown" #`uname -v`
BUILD_MACHINE_INFO="-DTRE_BIG_ENDIAN -DLIBC_PATH=\"$LIBC_PATH\" -DTRE_KERNEL_IDENT=\"$KERNEL_IDENT\" -DTRE_CPU_TYPE=\"$CPU_TYPE\" -DTRE_OS_RELEASE=\"$OS_RELEASE\" -DTRE_OS_VERSION=\"$OS_VERSION\""

GNU_LIBC_FLAGS="-D_GNU_SOURCE"
C_DIALECT_FLAGS="-ansi -Wall -Wextra"

CFLAGS="-pipe $C_DIALECT_FLAGS $GNU_LIBC_FLAGS $BUILD_MACHINE_INFO $ARGS"

DEBUGOPTS="-O0 -g"
BUILDOPTS="-O2 -march=native"
CRUNSHOPTS="-O2 -march=native -fwhole-program"
CRUNSHFLAGS="-DTRE_COMPILED_CRUNSHED -Ienvironment/transpiler/targets/c/native -Wno-unused-parameter"

LIBFLAGS="-lm -lffi -lrt"

if [ -f /lib/x86_64-linux-gnu/libdl.so* ]; then
	LIBFLAGS="$LIBFLAGS -ldl";
fi

COMPILED_ENV=${COMPILED_ENV:-"_compiled-env.c"}

if [ -f environment/transpiler/targets/c/native/$COMPILED_ENV ]; then
	FILES="$FILES $COMPILED_ENV";
	CFLAGS="$CFLAGS -DTRE_HAVE_COMPILED_ENV";
fi

CRUNSHTMP="tmp.c"
SBCL="sbcl --noinform"
TRE="$SBCL --core image"
BINDIR="/usr/local/bin/"

basic_clean ()
{
	echo "Cleaning..."
	rm -vrf obj compiled
	rm -vf *.core obj compiled environment/transpiler/targets/c/native/$COMPILED_ENV image bytecode-image $CRUNSHTMP __alien.tmp files.lisp
    rm -vf environment/transpiler/targets/c/native/_revision.h environment/_current-version
    rm -vf gmon.out tmp.gcda profile.lisp
	rm -vrf _nodejstests.log _phptests.log _bytecode-interpreter-tests.log make.log boot.log
	echo "Checking out last working core..."
    git checkout -- boot-common.lisp
}

distclean ()
{
	echo "Cleaning for distribution..."
    basic_clean
	rm -vrf backup
}

link ()
{
	echo "Linking..."
	OBJS=`find obj -name \*.o`
	$LD -o tre $OBJS $LIBFLAGS
}

make_revision_header ()
{
    REV=`git log --pretty=oneline | wc -l`
    REV=`expr 3290 + $REV`
    echo $REV >environment/_current-version
    echo "#ifndef TRE_REVISION" >environment/transpiler/targets/c/native/_revision.h
    echo "#define TRE_REVISION $REV" >>environment/transpiler/targets/c/native/_revision.h
    echo "#define TRE_REVISION_STRING \"$REV\"" >>environment/transpiler/targets/c/native/_revision.h
    echo "#endif" >>environment/transpiler/targets/c/native/_revision.h
}

standard_compile ()
{
    make_revision_header
	mkdir -p obj
	for f in $FILES; do
		echo "Compiling $f"
		$CC $CFLAGS $COPTS -c -o obj/$f.o environment/transpiler/targets/c/native/$f
	done
}

crunsh_compile ()
{
    make_revision_header
	rm -f $CRUNSHTMP
	echo "Compiling as one file for best optimisation..."
	echo -n "Concatenating sources:"
	for f in $FILES; do
		echo -n " $f"
		cat environment/transpiler/targets/c/native/$f >>$CRUNSHTMP
	done
	echo
	echo "Compiling..."
	$CC $CFLAGS $COPTS -o tre $CRUNSHTMP $LIBFLAGS
	rm $CRUNSHTMP
}

install_it ()
{
    echo "Installing 'tre' else to '$BINDIR'..."
	sudo cp tre $BINDIR
    sudo mkdir -p /usr/local/lib/tre
    echo "Installing SBCL image to '/usr/local/lib/tre/image'..."
    sudo cp image /usr/local/lib/tre
    echo "Installing environment to '/usr/local/lib/tre/environment/'..."
    sudo cp -r environment /usr/local/lib/tre
    echo "Done."
}

case $1 in
crunsh)
	CFLAGS="$CFLAGS $CRUNSHFLAGS"
	COPTS="$COPTS $CRUNSHOPTS"
	crunsh_compile
	;;

reload)
    echo "Reloading environment from source..."
    echo | ./tre -n
	;;

reloadnoassert)
    echo "Reloading environment from source..."
    echo | ./tre -n -e "(setq *assert* nil)(setq *targets* '(c))"
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
	echo "(precompile-environments)" | $TRE
	;;


compiler)
    echo "Compiling the compiler only..."
	echo "(compile-c-compiler)" | $TRE
    ;;

bcompiler)
    echo "Compiling the bytecode compiler only..."
	echo "(compile-c-environment '(compile-bytecode-environment))" | $TRE
	./make.sh crunsh $ARGS
    ;;

environment)
    echo "Compiling environment..."
	echo "(compile-c-environment)" | $TRE | tee boot.log
	;;

core)
    echo "Booting environment..."
    echo "(load \"boot-common.lisp\")" | $SBCL
	;;

genboot)
    echo "Compiling boot code with local image..."
    $SBCL --core image makefiles/boot-common-lisp.lisp
	;;

reset)
    echo "Resetting boot code from repository..."
    git checkout -- boot-common.lisp
	;;

boot)
    ./make.sh reset
    ./make.sh core
    ./make.sh genboot
    ./make.sh core
	;;

pgo)
    echo "Profile-guided optimization..."
	./make.sh crunsh -pg -fprofile-generate $ARGS
    mv environment/transpiler/targets/c/native/_compiled-env.c _ce.c
	./make.sh environment $ARGS
    mv _ce.c environment/transpiler/targets/c/native/_compiled-env.c
	./make.sh crunsh -fprofile-use $ARGS
	;;

ctests)
    echo "(do-tests)" | $TRE
	;;

phptests)
    echo "PHP target tests..."
    mkdir -p compiled
    $TRE tests/php.lisp
    php compiled/test.php >_phptests.log
    cmp tests/php.correct-output _phptests.log || (diff tests/php.correct-output _phptests.log; exit 1)
	;;

jstests)
    echo "JavaScript target tests..."
    mkdir -p compiled
    $TRE tests/js.lisp
    node compiled/test.js >_nodejstests.log
    chromium-browser compiled/test.html &
    cmp tests/js.correct-output _nodejstests.log || (diff tests/js.correct-output _nodejstests.log; exit 1)
    echo "JavaScript target tests passed in node.js."
	;;

updatetests)
    $TRE tests/php.lisp
    $TRE tests/js.lisp
    echo "Updating PHP target test data..."
    php compiled/test.php >tests/php.correct-output
    echo "Updating JavaScript target test data (node.js only)..."
    node compiled/test.js >tests/js.correct-output || node compiled/test.js >tests/js.correct-output
    ;;

tests)
    echo "Making tests..."
	./make.sh ctests
	./make.sh phptests
	./make.sh jstests
	;;

bytecode)
    echo "Making bytecodes for everything..."
	echo "(load-bytecode (compile-bytecode-environment))(dump-system \"image\")" | $TRE
	;;

bytecode-image)
    echo "Making bytecodes for everything..."
	echo "(with-output-file o \"bytecode-image\" (adolist ((compile-bytecode-environment)) (late-print ! o)))" | $TRE
	;;

nodeconsole)
    $TRE makefiles/nodeconsole.lisp
	;;

webconsole)
    $TRE makefiles/webconsole.lisp
	;;

jsdebugger)
    $TRE makefiles/debugger-js.lisp
    ;;

examples)
    $TRE examples/make-standard-js.lisp
    $TRE examples/make-standard-nodejs.lisp
    $TRE examples/make-standard-php.lisp
    echo "Making compiler dump for BUTLAST in examples/hello-world.lisp…"
    $TRE examples/make-compiler-dumps-for-butlast.lisp > compiled/compiler-dumps-for-butlast.lisp
#   $TRE examples/make-obfuscated.lisp # TODO: Fix setting the current *PACKAGE*.
    ;;

all)
    ./make.sh boot $ARGS
    ./make.sh tests
    ./make.sh examples
    ./make.sh nodeconsole
    ./make.sh webconsole
#    ./make.sh bytecode-image
#    ./make.sh jsdebugger
    echo "All done."
    ;;

extra)
    echo "Making complete compiler dump for examples/hello-world.lisp…"
    $TRE examples/make-compiler-dumps.lisp > compiled/compiler-dumps.lisp
    ;;

profile)
    echo "(= (transpiler-profile? *c-transpiler*) t)(compile-c-environment)" | $TRE
    ./make.sh crunsh
    echo "(with-profile (compile-c-environment))(with-output-file o \"profile.log\" (adolist ((profile)) (late-print ! o)))" | $TRE
    ;;

releasetests)
    echo "Making release tests..." | tee make.log
    ./make.sh all $ARGS
    ./make.sh extra
    echo "Release tests done." >>make.log
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
    cp -v environment/transpiler/targets/c/native/_compiled-env.c backup
    cp -v image backup
    echo "Backed up to backup/. Use 'restore' on occasion."
    ;;

restore)
    cp -v backup/tre .
    cp -v backup/_compiled-env.c environment/transpiler/targets/c/native
    cp -v backup/image .
    ;;

*)
	echo "Usage: make.sh [target]"
	echo "Targets:"
	echo "  boot            Build compiled environment from scratch."
	echo "  genboot         Generate CL core used to boot environment."
	echo "  reset           Check out boot-common.lisp from repository."

    echo "  examples        Compile everything in examples/."
    echo "  all             Compile almost everything."
    echo "  extra           Compile everything 'all' didn't compile."

    echo "  reload          Reload the environment."
    echo "  install         Install compiled executable and environment image."
    echo "  clean           Remove built files but not the backup."
    echo "  distclean       Like 'clean' but removes backups, too."
    echo "  webconsole      Make web browser REPL."
    echo "  nodeconsole     Make node.js REPL."
    echo "  ctests          Run C environemnt tests."
    echo "  jstests         Compile JavaScript target tests and run them with"
    echo "                  Chromium and node.js."
    echo "  phptests        Compile PHP target tests and run them with the"
    echo "                  command-line version of PHP."
	echo "  tests           Run all tests."
    echo "  updatetests     Generate new test reference files."
    echo "  releasetests    Run 'all' and everything that's hardly used."
    echo
    echo "Untested targets:"
    echo "  backup          Backup installation to local directory 'backup'."
    echo "  restore         Restore the last 'backup'."
    echo "  precompile      Precompile obligatory target environments (EXPERIMENTAL)."
    echo "  profile         Make a profile of the compiler compiling itself."
    echo
    echo "Broken targets:"
	echo "  compiler        Compile only C compiler to C."
	echo "  bcompiler       Compile only bytecode compiler to C."
    echo "  environment     Compile environment to C."
    echo "  bytecode        Compile environment to bytecode, replacing the functions."
    echo "  bytecode-image  Compile environment to PRINTed bytecode image."
    echo "  build           Compile C sources file by file. See also 'crunsh'."
    echo "  debug           Compile C sources for gdb. May the source be with you."
    echo "  crunsh          Compile C sources as one big file for best optimization."
    echo "  pgo             Compile C sources with profile-guided optimizations."

    ;;
esac
