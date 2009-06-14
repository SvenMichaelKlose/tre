;;;;; TRE environment
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun print-hex-digit (x &optional (str *standard-output*))
  (princ
    (code-char (if (< x 10)
      (+ #\0 x)
      (+ #\A -10 x)))
	str))

(defun print-hexbyte (x &optional (str *standard-output*))
  (with-default-stream s str
    (print-hex-digit (>> x 4) s)
    (print-hex-digit (mod x 16) s)))

(defun print-hexword (x &optional (str *standard-output*))
  (with-default-stream s str
    (print-hex-digit (mod (>> x 12) 16) s)
    (print-hex-digit (mod (>> x 8) 16) s)
    (print-hex-digit (mod (>> x 4) 16) s)
    (print-hex-digit (mod x 16) s)))
