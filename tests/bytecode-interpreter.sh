#!/bin/sh

./tre -i image tests/bytecode-interpreter.lisp | tee _bytecode-interpreter-tests.log
