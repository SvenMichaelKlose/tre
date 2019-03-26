;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun make-symbol (x &optional (pkg nil))
  (symbol x pkg))

(defun make-package (x)
  (symbol x nil))

(defun symbol-name (x)
  (?
    (eq t x) ,*t-symbol-name*
    x (? (symbol? x)
         x.n
         (progn
           (print x)
           (error "Symbol expected.")))
    ,*nil-symbol-name*))

(defun symbol-value (x)
  (?
    (eq t x) t
    (x.v)))

(defun symbol-function (x)
  (?
    (eq t x) nil
    x (x.f)))

(defun symbol-package (x)
  (?
    (not x) nil
    (eq t x) nil
    x.p))

(dont-obfuscate is_a)

(defun symbol? (x)
  (| (not x)
     (eq t x)
     (is_a x "__symbol")))
