;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun read-line (&optional (str *standard-input*))
  "Read line from string."
  (with-default-stream str
    (with-queue q
       (do ((c (read-char str) (read-char str)))
           ((or (= c 10) (= c 13) (end-of-file str))
            (return-from read-line (list-string (queue-list q))))
         (enqueue q c)))))

(defun read-integer (&optional (str *standard-input*))
  (with (rec	#'(()
				    (if (digit-char-p (peek-char str))
						(+ (- #\0 (read-char str)) (rec))
						   0)))
	  (when (digit-char-p (peek-char str))
		(rec))))
