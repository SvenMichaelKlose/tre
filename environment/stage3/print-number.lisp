;;;;; tré – Copyright (c) 2005–2009,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun digit (x)
  (code-char (? (< x 10)
                (+ #\0 x)
                (+ #\a -10 x))))

(defun integer-string (x n r)
  (with (f #'((x)
                (. (digit (mod x r))
                   (unless (zero? (--! n))
                     (f (integer (/ x r)))))))
    (list-string (reverse (f x)))))

(defun print-hex (x n str)
  (princ (integer-string x n 16) (default-stream str)))

(defun print-hexbyte (x &optional (str *standard-output*))
  (print-hex x 2 str))

(defun print-hexword (x &optional (str *standard-output*))
  (print-hex x 4 str))

(defun print-octal (x &optional (str *standard-output*))
  (princ (integer-string x 3 8) (default-stream str)))
