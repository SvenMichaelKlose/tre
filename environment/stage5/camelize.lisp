;;;;; tré – Copyright (c) 2011–2013 Sven Michael Klose <pixel@copei.de>

(defun camelize (x)
  (with (rec [& _
                (? (== _. #\-)
                   (cons (char-upcase ._.) (rec .._))
                   (cons _. (rec ._)))])
    (list-string (rec (string-list x)))))
