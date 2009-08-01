;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; This are the low-level transpiler definitions of
;;;;; basic functions to simulate basic data types.

(defun js-load-base (dir-path &rest files)
  (mapcan (fn (let f (+ dir-path _)
				(format t  "(js-load-base \"~A\")~%" f)
  				(read-file-all f)))
		  files))

;;;; First part of the core functions
;;;;
;;;; It contains the essential functions needed to store argument
;;;; definitions for APPLY.
(defvar *js-base*
	(js-load-base "transpiler/javascript/environment/"
		"return-value.lisp"
		"not.lisp"
		"cons.lisp"
		"symbol.lisp"))

;;;; Second part of the core functions
;;;;
;;;; Functions required by imported environment functions.
(defvar *js-base2*
	(append
		(js-load-base "transpiler/environment/"
			"assoc.lisp"
			"atom.lisp")
		(js-load-base "transpiler/javascript/environment/"
			"apply.lisp"
			"array.lisp"
			"atom.lisp"
			"bind.lisp"
			"character.lisp"
			"debug-print.lisp"
			"equality.lisp"
			"error.lisp"
			"late-argdefs.lisp"
			"late-cons.lisp"
			"late-symbol.lisp"
			"list.lisp"
			"number.lisp"
			"sequence.lisp"
			"stream.lisp"
			"string.lisp"
			"member.lisp"
			"hash.lisp")))
