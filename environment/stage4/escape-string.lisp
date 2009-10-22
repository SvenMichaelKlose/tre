;;;; TRE environment
;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun escape-charlist (x quote-char)
  (when x
    (if
	  (= quote-char x.)
        (cons #\\
              (cons x.
                    (escape-charlist .x quote-char)))
	  (= #\\ x.)
        (cons #\\
			  (if (and .x (digit-char-p .x.))
                  (escape-charlist .x quote-char)
                  (cons #\\
                        (escape-charlist .x quote-char))))
      (cons x.
            (escape-charlist .x quote-char)))))

(defun escape-string (x quote-char)
  (list-string (escape-charlist (string-list x) quote-char)))
