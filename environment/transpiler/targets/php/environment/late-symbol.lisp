;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun make-symbol (x &optional (pkg nil))
  (new __symbol x pkg))

(defun make-package (x)
  (new __symbol x nil))

(defun symbol-name (x)
  (if
    (eq t x)
      "T"
    x
  	  x.n
    ,*nil-symbol-name*))

(defun symbol-value (x) (when x x.v))
(defun symbol-function (x) (when x x.f))

(defun symbol-package (x)
  (if
    (or (not x)
        (eq t x))
      nil
    x
      x.p))

(dont-obfuscate is_a)

(defun symbolp (x)
  (is_a x "__symbol"))
