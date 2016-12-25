; tré – Copyright (c) 2008–2012,2016 Sven Michael Klose <pixel@hugbox.org>

(defvar *characters* (make-array))

(defun character? (x)
  (is_a x "__character"))

(defun code-char (x)
  (declare type number x)   ; TODO: No use to declare types here.
  (new __character x))

(defun char-code (x)
  (declare type character x)
  x.v)

(defun char-string (x)
  (declare type character x)
  (chr x.v))
