;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun js-load-base (dir-path &rest files)
  (mapcan [let f (+ dir-path _)
			(format t  "(js-load-base \"~A\")~%" f)
  			(read-file-all f)]
		  files))

;;;; First part of the core functions
;;;;
;;;; It contains the essential functions needed to store argument
;;;; definitions for APPLY.

(defvar *js-env-path* "environment/transpiler/targets/javascript/environment/")

(defvar *js-base*
	,(list 'quote (+ (js-load-base "environment/transpiler/environment/"
                                   "cps-disable.lisp")
	                 (js-load-base *js-env-path*
		                           "return-value.lisp"
                                   "log.lisp"
		                           "defined-functions.lisp"
		                           "cons.lisp"
		                           "symbol.lisp"
		                           "propertylist.lisp"))))

(defvar *js-base-debug-print* ,(list 'quote (js-load-base *js-env-path* "debug-print.lisp")))

;;;; Second part of the core functions
;;;;
;;;; Functions required by imported environment functions.

(defvar *js-base2*
	,(list 'quote (+ (js-load-base "environment/transpiler/environment/"
                                   "cps-disable.lisp"
		                           "not.lisp")
		             (js-load-base *js-env-path*
			                       "macro.lisp"
			                       "array.lisp"
			                       "character.lisp"
			                       "number.lisp"
			                       "../../../environment/number.lisp"
			                       "../../../environment/number-typing.lisp"
			                       "apply.lisp"
			                       "atom.lisp")
	 	             (js-load-base "environment/transpiler/environment/"
                                   "defvar-native.lisp"
                                   "character.lisp"
			                       "atom.lisp"
                                   "string.lisp")
		             (js-load-base *js-env-path*
                                   "predefined-symbols.lisp"))))

(= *js-base2* (+ *js-base2*
	             ,(list 'quote (js-load-base *js-env-path*
		                                     "bind.lisp"
		                                     "../../../environment/eq.lisp"
		                                     "../../../environment/equality.lisp"
		                                     "late-cons.lisp"
		                                     "late-symbol.lisp"
		                                     "../../../environment/list.lisp"
		                                     "../../../environment/sequence.lisp"
		                                     "sequence.lisp"
		                                     "../../../environment/list-string.lisp"
		                                     "string.lisp"
		                                     "hash.lisp"
                                             "base64.lisp"
                                             "function-source.lisp"
                                             "function-bytecode.lisp"
                                             "dot-expand.lisp"
                                             "math.lisp"))))

(when *have-compiler?*
  (= *js-base2* (+ *js-base2* ,(list 'quote (js-load-base *js-env-path* "native-eval.lisp")))))

(= *js-base2* (+ *js-base2*
	             ,(list 'quote (js-load-base "environment/transpiler/environment/"
                                             "setf-function-p.lisp"))))

(defvar *js-base-stream*
	,(list 'quote (+ (js-load-base *js-env-path*
			                       "error.lisp"
			                       "stream.lisp"
			                       "../../../environment/print.lisp"))))

(defvar *js-base-eval* ,(list 'quote (js-load-base *js-env-path* "eval.lisp")))
