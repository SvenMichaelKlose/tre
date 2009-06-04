;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defvar *keyword-package* t)

;; Make symbol in particular package.
(defun make-symbol (x &optional (pkg nil))
  (%lookup-symbol x pkg ))

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
	   (%%%= x.__class "symbol")))
