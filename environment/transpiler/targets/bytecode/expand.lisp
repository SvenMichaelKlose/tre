;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro define-bc-std-macro (&rest x)
  `(define-transpiler-std-macro *bc-transpiler* ,@x))

(define-bc-std-macro defun (name args &rest body)
  (shared-defun name args body))

(define-bc-std-macro %set-atom-fun (place value)
  `(setq ,place ,value))
