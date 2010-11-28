;;;; TRE transpiler environment
;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>

(defun list-string (lst)
  (let* ((n (length lst))
         (s (make-string n)))
    (do ((i 0 (integer-1+ i))
         (l lst (cdr l)))
        ((>= i n) s)
      (setf s (+ s (string (car l)))))))
