#!/bin/sh
# tré – Copyright (c) 2005–2016 Sven Michael Klose <pixel@hugbox.org>

set -e

ARGS="$2 $3 $4 $5 $6 $7 $8 $9"

SBCL="sbcl --noinform"
TRE="$SBCL --core image"
BINDIR="/usr/local/bin/"

basic_clean ()
{
	echo "Cleaning..."
	rm -vf *.core compiled environment/transpiler/targets/c/native/$COMPILED_ENV image files.lisp
    rm -vf environment/_current-version
	rm -vrf _nodejstests.log _phptests.log
	echo "Checking out last working core..."
    git checkout -- boot-common.lisp
}

distclean ()
{
	echo "Cleaning for distribution..."
    basic_clean
	rm -vrf backup
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
reload)
    echo "Reloading environment from source..."
    echo | ./tre -n
	;;

reloadnoassert)
    echo "Reloading environment from source..."
    echo | ./tre -n -e "(setq *assert* nil)(setq *targets* '(c))"
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
	./make.sh phptests
	./make.sh jstests
	;;

nodeconsole)
    $TRE makefiles/nodeconsole.lisp
	;;

webconsole)
    $TRE makefiles/webconsole.lisp
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
    echo "All done."
    ;;

extra)
    echo "Making complete compiler dump for examples/hello-world.lisp…"
    $TRE examples/make-compiler-dumps.lisp > compiled/compiler-dumps.lisp
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
    echo "  jstests         Compile JavaScript target tests and run them with"
    echo "                  Chromium and node.js."
    echo "  phptests        Compile PHP target tests and run them with the"
    echo "                  command-line version of PHP."
	echo "  tests           Run all tests."
    echo "  updatetests     Generate new test reference files."
    echo "  releasetests    Run 'all' and everything that's hardly used."

    ;;
esac
