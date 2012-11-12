;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defvar *characters* (make-array))

(dont-obfuscate __character)

(defun character? (x)
  (is_a x "__character"))

(defun code-char (x)
  (declare type number x)
  (new __character (%wrap-char-number x)))

(defun char-code (x)
  (declare type character x)
  x.v)

(dont-obfuscate from-char-code chr)

(defun char-string (x)
  (declare type character x)
  (chr x.v))
