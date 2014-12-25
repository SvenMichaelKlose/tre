; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun cl-load-base (dir-path &rest files)
  (mapcan [let f (+ dir-path _)
			(format t  "(cl-load-base \"~A\")~%" f)
  			(read-file f)]
		  files))

(defvar *cl-env-path* "environment/transpiler/targets/common-lisp/core/")

(defvar *cl-base*
	,(list 'quote (cl-load-base *cl-env-path*
                                "array.lisp"
                                "env-load.lisp"
                                "eval.lisp"
                                "file.lisp"
                                "function.lisp"
                                "global-variables.lisp"
                                "hash-table.lisp"
                                "image.lisp"
                                "list.lisp"
                                "load.lisp"
                                "macro.lisp"
                                "misc.lisp"
                                "number.lisp"
                                "object.lisp"
                                "string.lisp"
                                "symbol.lisp"
                                "variable.lisp")))
