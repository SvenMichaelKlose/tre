;;;;; TRE environment
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun octal-digit (x)
  (code-char (+ #\0 (mod x 8))))

(defun print-octal-0 (x)
  (when (< 0 x)
    (cons (octal-digit x)
		  (print-octal-0 (>> x 3)))))

(defun print-octal (x &optional (str *standard-output*))
  (princ (list-string (reverse (cons (octal-digit x)
									 (print-octal-0 (>> x 3)))))
		 str))
