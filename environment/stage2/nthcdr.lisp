;;;;; tré - Copyright (c) 2007,2011-2012 Sven Michael Klose <pixel@copei.de>

(functional nthcdr)

(defun nthcdr (idx lst)
  (when lst
    (? (integer= 0 idx)
       lst
       (nthcdr (integer-1- idx) (cdr lst)))))

(define-test "NTHCDR basically works"
  ((nthcdr 1 '(1 2 3 4)))
  '(2 3 4))
