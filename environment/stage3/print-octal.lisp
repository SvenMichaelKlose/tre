;;;;; tré – Copyright (c) 2005–2009,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun octal-digit (x)
  (code-char (+ #\0 (mod x 8))))

(defun print-octal (x &optional (str *standard-output*))
  (with (rec [& (< 0 x)
                (cons (octal-digit x)
		        (rec (>> x 3)))])
    (princ (list-string (reverse (cons (octal-digit x)
									   (rec (>> x 3)))))
		   (default-stream str))))
