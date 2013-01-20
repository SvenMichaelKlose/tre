;;;;; tré - Copyright (c) 2008-2013 Sven Michael Klose <pixel@copei.de>

(defun shared-defmacro (&rest x)
  (print-definition `(defmacro ,x. ,.x.))
  (eval (macroexpand `(define-transpiler-std-macro *transpiler* ,@x)))
  (when *have-compiler?*
    `(define-std-macro ,@x)))
