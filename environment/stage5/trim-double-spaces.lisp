;;;;; TRE environment
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun trim-double-spaces (x)
  (when x
    (if (and (= #\  x.)
             .x.
             (= #\  .x.))
      (trim-double-spaces .x)
      (cons x.
            (trim-double-spaces .x)))))

(defun string-trim-double-spaces (x)
  (list-string (trim-double-spaces (string-list x))))
