;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

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

(defvar *js-base0*
	,(list 'quote (+ (js-load-base *js-env-path*
		                           "return-value.lisp"))))
(defvar *js-base*
	,(list 'quote (+ (js-load-base *js-env-path*
                                   "%princ.lisp"
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
		                           "not.lisp"
                                   "exception.lisp"
                                   "cps-exceptions.lisp")
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
                                             "math.lisp"
                                             "nanotime.lisp"))))

(when *have-compiler?*
  (= *js-base2* (+ *js-base2* ,(list 'quote (js-load-base *js-env-path* "native-eval.lisp")))))

(= *js-base2* (+ *js-base2*
	             ,(list 'quote (js-load-base "environment/transpiler/environment/"
                                             "setf-function-p.lisp"))))

(defun js-base-stream ()
  (+ ,(list 'quote (js-load-base *js-env-path* "error.lisp"))
     ,(list 'quote (js-load-base *js-env-path* "../../../../stage3/stream.lisp"))
     (when (eq 'browser (transpiler-configuration *transpiler* 'environment))
       ,(list 'quote (js-load-base *js-env-path* "%force-output.lisp")))
     ,(list 'quote (js-load-base *js-env-path* "standard-stream.lisp"))
     ,(list 'quote (js-load-base *js-env-path* "../../../environment/print.lisp"))))

(defun js-base-nodejs ()
  (+ ,(list 'quote (js-load-base (+ *js-env-path* "node.js/")
                                 "file.lisp"))))

(defvar *js-base-eval* ,(list 'quote (js-load-base *js-env-path* "eval.lisp")))
