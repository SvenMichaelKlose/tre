#!/bin/sh

set -e

echo "Welcome to tré!"

git rev-parse --short=8 HEAD >environment/_git-revision
echo "Git revision is" `cat environment/_git-revision`
date >environment/_build-date
mkdir -p compiled

ARGS="$2 $3 $4 $5 $6 $7 $8 $9"

SBCL="sbcl --noinform"
TRE="./tre"
BINDIR="/usr/local/bin/"

SHCONFIG=`eval echo ~/.tre.sh`
if [ -e $SHCONFIG ]; then
    . $SHCONFIG
fi

clean_example_projects ()
{
	echo "Cleaning examples (requires root privileges to remove docker containers)…"
	sudo rm -rvf examples/project-js/compiled
	sudo rm -rvf examples/project-php/compiled
	sudo rm -rvf examples/project-js-php/compiled
}

clean ()
{
	echo "Cleaning…"
	rm -rvf compiled
	rm -vf *.core environment/transpiler/targets/c/native/$COMPILED_ENV image files.lisp
    rm -vf environment/_current-revision
    rm -vf environment/_build-date
	rm -vf log-nodetests.lisp log-phptests.lisp log-make.lisp
    clean_example_projects
	echo "Checking out last working core…"
    git checkout -- boot-common.lisp
}

install_it ()
{
    echo "Installing 'tre' to '$BINDIR'…"
	sudo cp tre $BINDIR
    sudo mkdir -p /usr/local/lib/tre
    echo "Installing SBCL image to '/usr/local/lib/tre/image'…"
    sudo cp -v image /usr/local/lib/tre
    echo "Installing environment to '/usr/local/lib/tre/environment/'…"
    sudo cp -rv environment modules /usr/local/lib/tre
    echo "Done."
}

case $1 in
core)
    echo "Booting environment…"
    echo "(load \"boot-common.lisp\")" | $SBCL
	;;

genboot)
    echo "Compiling boot code with local image…"
    $SBCL --core image makefiles/boot-common-lisp.lisp
	;;

reset)
    echo "Resetting boot code from repository…"
    git checkout -- boot-common.lisp
	;;

boot)
    ./make.sh reset
    ./make.sh core
    ./make.sh genboot
    ./make.sh core
	;;

phptests)
    echo "PHP target tests…"
    $TRE tests/php.lisp
    php compiled/test.php | tee log-phptests.lisp
    cmp tests/php.correct-output log-phptests.lisp || (diff tests/php.correct-output log-phptests.lisp; exit 1)
    for i in compiled/unit*.php; do php $i; done
	;;

jstests)
    echo "JavaScript target tests…"
    $TRE tests/js.lisp
    node compiled/test.js | tee log-nodetests.lisp
    #chromium-browser compiled/test.html &
    cmp tests/js.correct-output log-nodetests.lisp || (diff tests/js.correct-output log-nodetests.lisp; exit 1)
    for i in compiled/unit*.js; do node $i; done
    echo "JavaScript target tests passed in node.js."
	;;

updatetests)
    $TRE tests/php.lisp
    $TRE tests/js.lisp
    echo "Updating PHP target test data…"
    php compiled/test.php >tests/php.correct-output
    echo "Updating JavaScript target test data (node.js only)…"
    node compiled/test.js >tests/js.correct-output || node compiled/test.js >tests/js.correct-output
    ;;

tests)
    echo "Making tests…"
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
    $TRE examples/make-standard-node.lisp
    $TRE examples/make-standard-php.lisp
    $TRE examples/make-coreless-js.lisp
    echo "Making compiler dump for BUTLAST in examples/hello-world.lisp…"
#    $TRE examples/make-compiler-dumps-for-butlast.lisp > compiled/compiler-dumps-for-butlast.lisp
#   $TRE examples/make-obfuscated.lisp # TODO: Fix setting the current *PACKAGE*.
    ;;

all)
    echo "Making 'all'…"
    ./make.sh boot
    ./make.sh tests
    ./make.sh examples
    echo
    echo "Successfully built target 'all'."
    ;;

projects)
    clean_example_projects
    cd examples/project-php && ./make.sh && cd -
    cd examples/project-js && ./make.sh && cd -
    cd examples/project-js-php && ./make.sh && cd -
    ;;

release)
    echo "Making release tests…" | tee log-make.lisp
    ./make.sh clean
    ./make.sh all
    ./make.sh install
    ./make.sh projects
    echo "Release tests done." >>log-make.lisp
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
    echo "  projects      Make examples/project*."
    echo ""
    echo "  nodeconsole   Make node.js REPL. (defunct)"
    echo "  webconsole    Make web browser REPL. (defunct)"
    echo ""
    echo "  release       Make 'all' and 'nodeconsole'."
    echo "  updatetests   Generate new reference files from current test."

    ;;
esac
