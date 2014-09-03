#!/bin/sh

./make.sh clean && \
./make.sh crunsh && \
./make.sh reload && \
./make.sh bcompiler && \
echo "(bytecode-interpreter-tests)" | ./tre -i image | tee bytecode-interpreter-tests.log.txt
