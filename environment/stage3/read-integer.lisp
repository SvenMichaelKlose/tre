;;;;; tré - Copyright (c) 2008 Sven Michael Klose <pixel@copei.de>

(defun read-integer (&optional (str *standard-input*))
  "Read positive integer from stream."
  (with (rec #'((v)
			      (? (awhen (peek-char str)
					 (digit-char-p !))
					 (rec (+ (- (read-char str) #\0)
						     (* v 10)))
					 v)))
	(when (awhen (peek-char str)
		    (digit-char-p !))
	  (integer (rec 0)))))
