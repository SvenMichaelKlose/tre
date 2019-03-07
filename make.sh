#!/bin/sh

set -e

# Get revision number and date.
git log | grep ^commit | wc -l >environment/_current-version
date >environment/_release-date

ARGS="$2 $3 $4 $5 $6 $7 $8 $9"

SBCL="sbcl --noinform"
TRE="$SBCL --core image"
BINDIR="/usr/local/bin/"

clean ()
{
	echo "Cleaning..."
	rm -rvf compiled
	rm -vf *.core environment/transpiler/targets/c/native/$COMPILED_ENV image files.lisp
    rm -vf environment/_current-version
    rm -vf environment/_release-date
	rm -vf _nodejstests.log _phptests.log make.log
	echo "Checking out last working core..."
    git checkout -- boot-common.lisp
}

install_it ()
{
    echo "Installing 'tre' to '$BINDIR'..."
	sudo cp tre $BINDIR
    sudo mkdir -p /usr/local/lib/tre
    echo "Installing SBCL image to '/usr/local/lib/tre/image'..."
    sudo cp image /usr/local/lib/tre
    echo "Installing environment to '/usr/local/lib/tre/environment/'..."
    sudo cp -r environment /usr/local/lib/tre
    echo "Done."
}

case $1 in
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
    echo "Making defunct 'nodeconsole'…"
    $TRE makefiles/nodeconsole.lisp
	;;

webconsole)
    echo "Making defunct 'webconsole'…"
    $TRE makefiles/webconsole.lisp
	;;

examples)
    echo "Making directory 'examples'…"
    $TRE examples/make-standard-js.lisp
    $TRE examples/make-standard-nodejs.lisp
    $TRE examples/make-standard-php.lisp
    echo "Making compiler dump for BUTLAST in examples/hello-world.lisp…"
    $TRE examples/make-compiler-dumps-for-butlast.lisp > compiled/compiler-dumps-for-butlast.lisp
#   $TRE examples/make-obfuscated.lisp # TODO: Fix setting the current *PACKAGE*.
    ;;

all)
    echo "Making 'all'…"
    ./make.sh boot $ARGS
    ./make.sh tests
    ./make.sh examples
    echo "All done."
    ;;

extra)
    echo "Making 'extra'…"
    ./make.sh nodeconsole
    echo "Making complete compiler dump of examples/hello-world.lisp…"
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
	clean
	;;
*)
	echo "Usage: make.sh [target]"
    echo ""
	echo "Targets:"
	echo "  genboot       Generate CL code for target 'core'."
	echo "  reset         Check out boot-common.lisp from repository."
	echo "                (E.g. when 'genboot' went wrong.)"
	echo "  core          Load environment from scratch."
	echo "  boot          Make 'core', 'genboot' then 'core' again."
    echo "  install       Install executable and environment image made"
    echo "                by 'core' or 'boot',"
    echo "  clean         Remove built files, except 'genboot'."
    echo ""
	echo "  tests         Run tests defined in the environment."
    echo "  jstests       Only do 'tests' with Chromium browser and node.js."
    echo "  phptests      Only do 'tests' with command-line PHP."
    echo ""
    echo "  examples      Compile everything in directory 'examples'."
    echo "  all           Compile everything listed until here."
    echo "  extra         Also compiles what's listed below."
    echo ""
    echo "  nodeconsole   Make node.js REPL. (defunct)"
#    echo "  webconsole    Make web browser REPL. (defunct)"
    echo ""
    echo "  releasetests  Make 'all', 'extra' and 'nodeconsole'."
    echo "  updatetests   Generate new reference files from current test."

    ;;
esac
