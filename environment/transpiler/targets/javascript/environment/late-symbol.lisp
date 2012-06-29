;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun make-symbol (x &optional (pkg nil))
  (symbol x pkg))

(defun make-package (x)
  (symbol x nil))

(defvar *keyword-package* (make-package ""))

(defun symbol-name (x)
  (?
    (%%%eq t x) ,*t-symbol-name*
    (%%%eq false x) "FALSE"
    x x.n
    ,*nil-symbol-name*))

(defun symbol-value (x)
  (?
    (%%%eq t x) t
    x x.v))

(defun symbol-function (x)
  (?
    (%%%eq t x) nil
    x x.f))

(defun symbol-package (x)
  (?
    (%%%eq t x) nil
    x x.p))

(defun symbol? (x)
  (| (not x)
     (%%%eq t x)
     (& (object? x)
	     x.__class
         (%%%== x.__class ,(transpiler-obfuscated-symbol-string *current-transpiler* 'symbol)))))
