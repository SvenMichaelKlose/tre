;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; This are the low-level transpiler definitions of
;;;;; basic functions to simulate basic data types.

(defun php-load-base (dir-path &rest files)
  (mapcan (fn (let f (+ dir-path _)
				(format t  "(php-load-base \"~A\")~%" f)
  				(read-file-all f)))
		  files))

(defvar *php-env-path* "environment/transpiler/targets/php/environment/")

;;;; First part of the core functions
;;;;
;;;; It contains the essential functions needed to store argument
;;;; definitions for APPLY.
(defvar *php-base*
	(php-load-base *php-env-path*
		"return-value.lisp"
		"not.lisp"
		"cons.lisp"
		"symbol.lisp"))

;(defvar *php-base-debug-print*
;		(php-load-base *php-env-path*
;			"debug-print.lisp"))

;;;; Second part of the core functions
;;;;
;;;; Functions required by imported environment functions.
(defvar *php-base2*
	(append
		(php-load-base *php-env-path*
			"apply.lisp"
			"array.lisp"
			"atom.lisp")
		(php-load-base "environment/transpiler/environment/"
			"atom.lisp")
		(php-load-base *php-env-path*
			"bind.lisp"
			"character.lisp"
			"eq.lisp"
			"../../../environment/equality.lisp"
			"error.lisp"
			"late-cons.lisp"
			"late-symbol.lisp"
			"../../../environment/list.lisp"
			"number.lisp"
			"../../../environment/number.lisp"
			"../../../environment/number-typing.lisp"
			"sequence.lisp"
			"../../../environment/sequence.lisp"
			"standard-stream.lisp"
			"stream.lisp"
			"../../../environment/print.lisp"
			"../../../environment/list-string.lisp"
			"string.lisp"
			"../../../environment/member.lisp"
			"hash.lisp")
		(php-load-base "environment/transpiler/environment/"
			"assoc.lisp")))
