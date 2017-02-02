(defvar *cl-builtins* nil)

(fn cl-load-base (dir-path &rest files)
  (apply #'+ (@ [alet (+ dir-path _)
			      (print-definition `(cl-load-base ,!))
                  (with-temporary *package* (make-symbol "TRE-CORE")
                    (load-file !))
  			      (fetch-file !)]
		        files)))

(defvar *cl-core-path* "environment/transpiler/targets/common-lisp/core/")

(defvar *cl-core*
	,(cl-load-base *cl-core-path*
                   "global-variables.lisp"
                   "defbuiltin.lisp"
                   "array.lisp"
                   "env-load.lisp"
                   "../make-lambdas.lisp"
                   "error.lisp"
                   "eval.lisp"
                   "file.lisp"
                   "function.lisp"
                   "hash-table.lisp"
                   "image.lisp"
                   "list.lisp"
                   "load.lisp"
                   "macro.lisp"
                   "misc.lisp"
                   "number.lisp"
                   "object.lisp"
                   "sequence.lisp"
                   "string.lisp"
                   "special.lisp"
                   "symbol.lisp"
                   "unix-sh.lisp"))
