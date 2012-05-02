;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defun shared-defmacro (&rest x)
  (when *show-definitions*
    (late-print `(defmacro ,x. ,.x.)))
  (eval (macroexpand `(define-transpiler-std-macro *current-transpiler* ,@x)))
  (when *have-compiler?*
    `(define-std-macro ,@x)))
