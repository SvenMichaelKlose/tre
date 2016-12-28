(defvar *characters* (make-array))

(defun character? (x)
  (is_a x "__character"))

(defun code-char (x)
  (declare type number x)
  (new __character x))

(defun char-code (x)
  (declare type character x)
  x.v)

(defun char-string (x)
  (declare type character x)
  (chr x.v))
