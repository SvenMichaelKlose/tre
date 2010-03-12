;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

;; Make symbol in particular package.
(defun make-symbol (x &optional (pkg nil))
  (symbol x pkg))

;; Make package (which is just a symbol).
(defun make-package (x)
  (symbol x nil))

(defvar *keyword-package* (make-package ""))

(defun symbol-name (x)
  (if x
  	  x.n
	  ,*nil-symbol-name*))

(defun symbol-value (x) (when x x.v))
(defun symbol-function (x) (when x x.f))
(defun symbol-package (x) (when x x.p))

(defun symbolp (x)
  (and (objectp x)
	   x.__class
       (%%%= x.__class ,(transpiler-obfuscated-symbol-string
							*current-transpiler* 'symbol))))
