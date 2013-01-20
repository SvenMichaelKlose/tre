;;;;; tré – Copyright (c) 2008–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defmacro when-debug (&body x)
  (when (transpiler-assert? *transpiler*)
	`(progn
	   ,@x)))

(defmacro unless-debug (&body x)
  (unless (transpiler-assert? *transpiler*)
	`(progn
	   ,@x)))

(defmacro if-debug (consequence alternative)
  (? (transpiler-assert? *transpiler*)
	 consequence
	 alternative))
