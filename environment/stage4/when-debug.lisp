;;;;; Caroshi ECMAScript library
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Cancel out expression when compiling public version.

(defmacro when-debug (&rest x)
  (when *transpiler-assert*
	`(progn
	   ,@x)))

(defmacro unless-debug (&rest x)
  (unless *transpiler-assert*
	`(progn
	   ,@x)))

(defmacro if-debug (consequence alternative)
  (if *transpiler-assert*
	  consequence
	  alternative))
