;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defvar *characters* (make-array))

(defun %character (x)
  (or (aref *characters* x)
  	  (setf this.__class "%character"
  		    this.v x
		    (aref *characters* x) this)))

(defun characterp (x)
  (and (objectp x)
	   x.__class
	   (%%%= x.__class "%character")))

(defun code-char (x)
  (if (characterp x)
	  x
	  (new %character x)))

(defun char-code (x) x.v)
(defun char-string (x) (*string.from-char-code (char-code x)))
