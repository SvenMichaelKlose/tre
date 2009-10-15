;;;; TRE environment
;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun escape-charlist (x &key (quote-char #\"))
  (when x
    (if
	  (= quote-char x.)
        (cons #\\
              (cons x.
                    (escape-charlist .x :quote-char quote-char)))
	  (= #\\ x.)
        (cons #\\
			  (if (and .x (digit-char-p .x.))
                  (escape-charlist .x :quote-char quote-char)
                  (cons #\\
                        (escape-charlist .x :quote-char quote-char))))
      (cons x.
            (escape-charlist .x :quote-char quote-char)))))

(defun escape-string (x &key (quote-char #\"))
  (list-string (escape-charlist (string-list x)
								:quote-char quote-char)))
