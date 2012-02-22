;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defun make-symbol (x &optional (pkg nil))
  (symbol x pkg))

(defun make-package (x)
  (symbol x nil))

(defun symbol-name (x)
  (?
    (%%%eq t x) "T"
    x x.n
    ,*nil-symbol-name*))

(defun symbol-value (x) (when x x.v))
(defun symbol-function (x) (when x x.f))

(defun symbol-package (x)
  (unless (or (not x) (%%%eq t x))
    x.p))

(dont-obfuscate is_a)

(defun symbol? (x)
  (or (not x)
      (is_a x "__symbol")))
