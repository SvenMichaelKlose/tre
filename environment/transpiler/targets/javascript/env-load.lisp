;;;;; tré - Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

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
	,(list 'quote (append (js-load-base
                 "environment/transpiler/environment/"
                 "cps-disable.lisp")
	         (js-load-base *js-env-path*
                 "opt-inline.lisp"
		         "return-value.lisp"
                 "log.lisp"
		         "defined-functions.lisp"
		         "not.lisp"
		         "cons.lisp"
		         "symbol.lisp"
		         "propertylist.lisp"))))

(defvar *js-base-debug-print* ,(list 'quote (js-load-base *js-env-path* "debug-print.lisp")))

;;;; Second part of the core functions
;;;;
;;;; Functions required by imported environment functions.

(defvar *js-base2*
	,(list 'quote (append
	     (js-load-base "environment/transpiler/environment/"
             "cps-disable.lisp")
		 (js-load-base *js-env-path*
			 "macro.lisp"
			 "character.lisp"
			 "number.lisp"
			 "../../../environment/number.lisp"
             )
			 ;"../../../environment/number-typing.lisp")
		 (js-load-base *js-env-path*
			 "apply.lisp"
			 "array.lisp"
			 "atom.lisp")
	 	 (js-load-base "environment/transpiler/environment/"
             "character.lisp"
			 "atom.lisp"))))
(setf *js-base2* (append *js-base2*
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
			                                         "../../../environment/member.lisp"
			                                         "hash.lisp"
                                                     "base64.lisp"
                                                     "function-source.lisp"
                                                     "dot-expand.lisp"))))

(when *have-compiler?*
  (setf *js-base2* (append *js-base2* ,(list 'quote (js-load-base *js-env-path* "native-eval.lisp")))))

(setf *js-base2* (append *js-base2*
		         ,(list 'quote (js-load-base "environment/transpiler/environment/"
			                                 "assoc.lisp"
                                             "setf-function-p.lisp"))))

(defvar *js-base-stream*
	,(list 'quote (append
		 (js-load-base *js-env-path*
			 "error.lisp"
			 "stream.lisp"
			 "../../../environment/print.lisp"))))

(defvar *js-base-eval* ,(list 'quote (js-load-base *js-env-path* "eval.lisp")))
