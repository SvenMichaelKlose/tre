;;;;; tré - Copyright (c) 2008 Sven Michael Klose <pixel@copei.de>

(defun digit-number (x)
  (- x #\0))

(defun peek-digit (str)
  (awhen (peek-char str)
    (and (digit-char-p !) !)))

(defun peek-dot (str)
  (awhen (peek-char str)
    (eq #\. !)))

(defun read-mantissa (&optional (str *standard-input*))
  "Read positive integer from stream."
  (with (rec #'((v s)
			      (? (peek-digit str)
					 (rec (+ v (* s (digit-number (read-char str))))
                          (/ s 10))
					 v)))
	(when (awhen (peek-char str)
		    (digit-char-p !))
	  (rec 0 0.1))))

(defun read-integer (&optional (str *standard-input*))
  "Read positive integer from stream."
  (with (rec #'((v)
			      (? (peek-digit str)
					 (rec (+ (* v 10) (digit-number (read-char str))))
					 v)))
	(when (peek-digit str)
	  (integer (rec 0)))))

(defun read-number (&optional (str *standard-input*))
  (+ (read-integer str)
     (or (and (peek-dot str)
              (read-char str)
              (read-mantissa str))
         0)))
