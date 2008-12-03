;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun read-integer (&optional (str *standard-input*))
  "Read positive integer from stream."
  (with (rec #'((v)
			      (if (awhen (peek-char str)
						(digit-char-p !))
					  (rec (+ (- (read-char str) #\0)
							  (* v 10)))
					  v)))
	(when (awhen (peek-char str)
		    (digit-char-p !))
	  (integer (rec 0)))))
