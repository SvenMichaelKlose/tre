;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

;; Make symbol in particular package.
(defun make-symbol (x &optional (pkg nil))
  (symbol x pkg))

;; Make package (which is just a symbol).
(defun make-package (x)
  (symbol x nil))

(defvar *keyword-package* (make-package ""))

(defun symbol-name (x)
  (?
    (%%%= t x) ,*t-symbol-name*
    x x.n
    ,*nil-symbol-name*))

(defun symbol-value (x)
  (?
    (%%%= t x) t
    x x.v))

(defun symbol-function (x)
  (?
    (%%%= t x) nil
    x x.f))

(defun symbol-package (x)
  (?
    (%%%= t x) nil
    x x.p))

(defun symbol? (x)
  (or (not x)
      (%%%= t x)
      (and (object? x)
	       x.__class
           (%%%= x.__class ,(transpiler-obfuscated-symbol-string *current-transpiler* 'symbol)))))
