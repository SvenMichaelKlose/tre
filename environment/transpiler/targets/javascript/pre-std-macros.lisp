;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defmacro define-js-pre-std-macro (&rest x)
  `(define-transpiler-pre-std-macro *js-transpiler* ,@x))

;(define-js-pre-std-macro defun (name args &rest body)
;  (let dname (transpiler-package-symbol *js-transpiler* (%defun-name name))
;    (js-cps-exception name)
;    (when (in-cps-mode?)
;      (transpiler-add-cps-function *js-transpiler* dname))
;    (let g '~%tfun
;      `(progn
;         ,@(js-make-early-symbol-expr g dname)
;         ,@(apply #'shared-defun dname args body)
;	     (setf (symbol-function ,g) ,dname)))))
