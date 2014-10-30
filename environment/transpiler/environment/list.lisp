;;;;; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(declare-cps-exception list-length)

(defun list-length (x)
  (let len 0
    (while (cons? x)
           len
      (= x .x)
      (++! len))))

(defun last (x)
  (& x
     (? .x
        (last .x)
        x)))

(defun copy-list (x)
  (? (atom x)
     x
     (. x. (copy-list .x))))

(functional nthcdr)

(defun nthcdr (idx x)
  (& x
     (? (zero? idx)
        x
        (nthcdr (-- idx) .x))))

(functional nth)

(defun nth (i x)
  (car (nthcdr i x)))

(defun filter (func lst)
  (let result (. nil nil)
    (dolist (i lst .result)
      (rplaca result
              (cdr (rplacd (| result.
                              result)
                           (list (funcall func i))))))))
