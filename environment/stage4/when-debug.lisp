;;;;; tré - Copyright (c) 2008-2010,2012 Sven Michael Klose <pixel@copei.de>

(defmacro when-debug (&body x)
  (when *transpiler-assert*
	`(progn
	   ,@x)))

(defmacro unless-debug (&body x)
  (unless *transpiler-assert*
	`(progn
	   ,@x)))

(defmacro if-debug (consequence alternative)
  (? *transpiler-assert*
	 consequence
	 alternative))
