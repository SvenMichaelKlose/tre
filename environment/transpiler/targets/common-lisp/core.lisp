(var *cl-builtins* nil)

(fn cl-load-base (dir-path &rest files)
  (apply #'+ (@ [!= (+ dir-path _)
                  (print-definition `(cl-load-base ,!))
                  (with-temporary *package* "TRE-CORE"
                    (load-file !))
                  (fetch-file !)]
                files)))

(var *cl-core-path* "environment/transpiler/targets/common-lisp/core/")

(var *cl-core*
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
                   "string.lisp"
                   "special.lisp"
                   "symbol.lisp"
                   "unix-sh.lisp"))
