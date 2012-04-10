;;;;; tré - Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun escape-charlist (x quote-char chars-to-escape)
  (when x
    (?
	  (= quote-char x.)
        (cons #\\ (cons x. (escape-charlist .x quote-char chars-to-escape)))
	  (= #\\ x.)
        (cons #\\ (? (and .x (digit-char-p .x.))
                     (escape-charlist .x quote-char chars-to-escape)
                     (cons #\\ (escape-charlist .x quote-char chars-to-escape))))
      (member x. chars-to-escape :test #'character=)
        (cons #\\ (cons x. (escape-charlist .x quote-char chars-to-escape)))
      (cons x. (escape-charlist .x quote-char chars-to-escape)))))

(defun escape-string (x quote-char &optional (chars-to-escape nil))
  (list-string (escape-charlist (string-list x) quote-char chars-to-escape)))
