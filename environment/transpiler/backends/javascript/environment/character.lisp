;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defvar *characters* (make-array))

(dont-inline %character)

(defun %character (x)
  (declare type number x)
  (assert (not (characterp x))
		  (error "%CHARACTER: argument already a character"))
  (or (aref *characters* x)
  	  (setf this.__class ,(transpiler-obfuscated-symbol-string *current-transpiler*
											  				   '%character)
  		    this.v x
		    (aref *characters* x) this)))

(defun characterp (x)
  (and (objectp x)
	   x.__class
	   (%%%= x.__class ,(transpiler-obfuscated-symbol-string *current-transpiler*
															 '%character))))

(defun code-char (x)
  (declare type number x)
  (if (characterp x)
	  x
	  (new %character x)))

(defun char-code (x)
  (declare type number x)
  x.v)

(dont-obfuscate from-char-code)

(defun char-string (x)
  (declare type character x)
  (*string.from-char-code (char-code x)))
