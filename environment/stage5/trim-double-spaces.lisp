;;;;; tré - Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defun trim-double-spaces (x)
  (when x
    (? (and (= #\  x.)
            .x.
            (= #\  .x.))
       (trim-double-spaces .x)
       (cons x. (trim-double-spaces .x)))))

(defun string-trim-double-spaces (x)
  (list-string (trim-double-spaces (string-list x))))
