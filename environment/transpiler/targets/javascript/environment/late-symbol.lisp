;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

;; Make symbol in particular package.
(defun make-symbol (x &optional (pkg nil))
  (symbol x pkg))

;; Make package (which is just a symbol).
(defun make-package (x)
  (symbol x nil))

(defvar *keyword-package* (make-package ""))

(defun symbol-name (x)
  (? x
  	 x.n
	 ,*nil-symbol-name*))

(defun symbol-value (x) (when x x.v))
(defun symbol-function (x) (when x x.f))
(defun symbol-package (x) (when x x.p))

(defun symbol? (x)
  (or (not x)
      (and (object? x)
	       x.__class
           (%%%= x.__class ,(transpiler-obfuscated-symbol-string *current-transpiler* 'symbol)))))
