;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun camelize (x)
  (with (rec #'((x)
                 (when x
                   (? (= x. #\-)
                      (cons (char-upcase .x.) (rec ..x))
                      (cons x. (rec .x))))))
    (list-string (rec (string-list x)))))
