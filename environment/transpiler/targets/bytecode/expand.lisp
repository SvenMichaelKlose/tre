;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defmacro define-bc-std-macro (name args &body body)
  `(define-transpiler-std-macro *bc-transpiler* ,name ,args ,@body))

(define-bc-std-macro defun (name args &body body)
  (shared-defun name args body))

(define-bc-std-macro %set-atom-fun (place value)
  `(setq ,place ,value))
