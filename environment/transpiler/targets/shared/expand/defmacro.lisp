;;;;; tré - Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun shared-defmacro (tr-name &rest x)
  (when *show-definitions*
    (late-print `(defmacro ,x. ,.x.)))
  (eval (macroexpand `(define-transpiler-std-macro ,tr-name ,@x)))
  (when *have-compiler?*
    (print `(define-std-macro ,@x))))
