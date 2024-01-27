The tré compiler
================

The compiler breaks up its input into the smallest possible units while
combining it with gathered information to then clean up the mess and generate
code for the desired target platform.  These steps are performed in the front-,
middle- and back-end respectively.  They are numerous, relatively simple and
incremental in a tangible fashion.[^1]

[^1]: Keyword "Micro-pass architecture".
