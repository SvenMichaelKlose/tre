;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defvar *characters* (make-array))

(dont-obfuscate __character)

(defun character? (x)
  (is_a x "__character"))

(defun code-char (x)
  (declare type number x)
  (? (character? x)
	 x
	 (new __character x)))

(defun char-code (x)
  (declare type number x)
  x.v)

(dont-obfuscate from-char-code chr)

(defun char-string (x)
  (declare type character x)
  (chr x.v))
