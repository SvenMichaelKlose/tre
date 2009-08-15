;;;;; Caroshi ECMAScript library
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Cancel out expression when compiling public version.

(defmacro when-debug (&rest x)
  (when *transpiler-assert*
	`(progn
	   ,@x)))
