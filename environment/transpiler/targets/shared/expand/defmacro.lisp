;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defun shared-defmacro (tr-name &rest x)
  (when *show-definitions*
    (late-print `(defmacro ,@x.)))
  (eval (macroexpand `(define-transpiler-std-macro ,tr-name ,@x)))
  nil)
