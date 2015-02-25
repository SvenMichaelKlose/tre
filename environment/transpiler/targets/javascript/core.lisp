; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@copei.de>

(defvar *js-core-path* "environment/transpiler/targets/javascript/core/")

(defun js-load-core (dir-path &rest files)
  (mapcan [let f (+ *js-core-path* dir-path _)
			(format t  "(js-load-core \"~A\")~%" f)
  			(read-file f)]
		  files))

(defvar *js-core0* ,(list 'quote (js-load-core "" "return-value.lisp")))
(defvar *js-core*
	,(list 'quote (js-load-core ""
                                "%princ.lisp"
		                        "defined-functions.lisp"
		                        "cons.lisp"
		                        "symbol.lisp"
		                        "propertylist.lisp")))

(defvar *js-core-debug-print* ,(list 'quote (js-load-core "" "debug-print.lisp")))

(defvar *js-core2*
	,(list 'quote (+ (js-load-core "../../../environment/"
		                           "not.lisp"
                                   "exception.lisp"
                                   "cps-exceptions.lisp")
		             (js-load-core ""
			                       "macro.lisp"
			                       "array.lisp"
			                       "character.lisp"
			                       "number.lisp"
			                       "../../../environment/number.lisp"
			                       "../../../environment/number-typing.lisp"
			                       "apply.lisp"
			                       "atom.lisp")
	 	             (js-load-core "../../../environment/"
			                       "atom.lisp"
                                   "string.lisp")
		             (js-load-core ""
                                   "predefined-symbols.lisp"))))

(= *js-core2* (+ *js-core2*
	             ,(list 'quote (js-load-core ""
		                                     "bind.lisp"
		                                     "../../../environment/eq.lisp"
		                                     "../../../environment/equality.lisp"
		                                     "late-cons.lisp"
		                                     "late-symbol.lisp"
		                                     "../../../environment/list.lisp"
		                                     "../../../environment/append.lisp"
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
  (= *js-core2* (+ *js-core2* ,(list 'quote (js-load-core "" "native-eval.lisp")))))

(= *js-core2* (+ *js-core2* ,(list 'quote (js-load-core "" "../../../environment/setf-function-p.lisp"))))

(defun js-core-stream ()
  (+ ,(list 'quote (js-load-core "" "error.lisp"))
     ,(list 'quote (js-load-core "" "../../../../stage3/stream.lisp"))
     (& (eq :browser (configuration :platform))
        ,(list 'quote (js-load-core "" "%force-output.lisp")))
     ,(list 'quote (js-load-core "" "standard-stream.lisp"))
     ,(list 'quote (js-load-core "" "../../../environment/print.lisp"))))

(defun js-core-nodejs ()
  (+ ,(list 'quote (js-load-core "node.js/" "file.lisp"))))

(defvar *js-core-eval* ,(list 'quote (js-load-core "" "eval.lisp")))
