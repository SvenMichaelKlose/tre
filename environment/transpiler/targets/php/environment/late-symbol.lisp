;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

;; Make symbol in particular package.
(defun make-symbol (x &optional (pkg nil))
  (new __symbol x pkg))

;; Make package (which is just a symbol).
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
    (eq t x)
      nil
    x
      x.p))

(dont-obfuscate is_a)

(defun symbolp (x)
  (is_a x "__symbol"))
