;;;;; tré – Copyright (c) 2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun escape-charlist (x &optional (quote-char #\") (chars-to-escape #\"))
  (when x
    (= chars-to-escape (force-list chars-to-escape))
    (?
	  (== quote-char x.)
        (cons #\\ (cons x. (escape-charlist .x quote-char chars-to-escape)))
	  (== #\\ x.)
        (cons #\\ (? (& .x (digit-char? .x.))
                     (escape-charlist .x quote-char chars-to-escape)
                     (cons #\\ (escape-charlist .x quote-char chars-to-escape))))
      (member x. chars-to-escape :test #'character==)
        (cons #\\ (cons x. (escape-charlist .x quote-char chars-to-escape)))
      (cons x. (escape-charlist .x quote-char chars-to-escape)))))

(defun escape-string (x &optional (quote-char #\") (chars-to-escape #\"))
  (list-string (escape-charlist (string-list x) quote-char chars-to-escape)))
