; tré – Copyright (c) 2008–2012,2016 Sven Michael Klose <pixel@hugbox.org>

(defvar *characters* (make-array))

(dont-obfuscate __character)

(defun character? (x)
  (is_a x "__character"))

(defun code-char (x)
  (declare type number x)
  (new __character x))

(defun char-code (x)
  (declare type character x)
  x.v)

(dont-obfuscate from-char-code chr)

(defun char-string (x)
  (declare type character x)
  (chr x.v))
