; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@copei.de>

(defvar *cl-builtins* nil)

(defun cl-load-base (dir-path &rest files)
  (mapcan [alet (+ dir-path _)
			(format t  "(cl-load-base \"~A\")~%" !)
  			(read-file !)]
		  files))

(defvar *cl-core-path* "environment/transpiler/targets/common-lisp/core/")

(defvar *cl-core*
	,(list 'quote (cl-load-base *cl-core-path*
                                "global-variables.lisp"
                                "defbuiltin.lisp"
                                "array.lisp"
                                "env-load.lisp"
                                "../make-lambdas.lisp"
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
                                "symbol.lisp")))
