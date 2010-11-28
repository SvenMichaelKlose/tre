;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
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

(defvar *js-env-path* "environment/transpiler/targets/javascript/environment/")

(defvar *js-base*
	(append (js-load-base "environment/transpiler/environment/"
                "cps-disable.lisp")
	        (js-load-base *js-env-path*
		        "return-value.lisp"
		        "not.lisp"
		        "cons.lisp"
		        "symbol.lisp"
		        "propertylist.lisp")
		    (js-load-base "environment/transpiler/environment/"
                "cps-enable.lisp")))

(defvar *js-base-debug-print*
		(js-load-base *js-env-path*
			"debug-print.lisp"))

;;;; Second part of the core functions
;;;;
;;;; Functions required by imported environment functions.
(defvar *js-base2*
	(append
	    (js-load-base "environment/transpiler/environment/"
            "cps-disable.lisp")
		(js-load-base *js-env-path*
			"character.lisp"
			"number.lisp"
			"number-typing.lisp")
		(js-load-base "environment/transpiler/environment/"
            "cps-enable.lisp")
		(js-load-base *js-env-path*
			"apply.lisp"
			"array.lisp"
			"atom.lisp")
		(js-load-base "environment/transpiler/environment/"
			"atom.lisp")
		(js-load-base *js-env-path*
			"bind.lisp"
			"equality.lisp"
			"../../../environment/error.lisp"
			"late-cons.lisp"
			"late-symbol.lisp"
			"../../../environment/list.lisp"
			"sequence.lisp"
			"stream.lisp"
			"print.lisp"
			"string.lisp"
			"member.lisp"
			"hash.lisp")
		(js-load-base "environment/transpiler/environment/"
			"assoc.lisp")))
