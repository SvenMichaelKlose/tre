;;;; TRE environment
;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun escape-charlist (x)
  (when x
    (if (= #\" x.)
        (cons #\\
              (cons x.
                    (escape-charlist .x)))
        (cons x.
              (escape-charlist .x)))))

(defun escape-string (x)
  (list-string (escape-charlist (string-list x))))
