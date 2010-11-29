;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defvar *characters* (make-array))

(dont-obfuscate __character)

(defun characterp (x)
  (is_a x "__character"))

(defun code-char (x)
  (declare type number x)
  (if (characterp x)
	  x
	  (new __character x)))

(dont-obfuscate get-code)

(defun char-code (x)
  (declare type number x)
  (x.get-code))

(dont-obfuscate from-char-code chr)

(defun char-string (x)
  (declare type character x)
  (chr (char-code x)))
