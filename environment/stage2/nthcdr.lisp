;;;;; nix operating system project
;;;;; Copyright (c) 2007 Sven Klose <pixel@copei.de>

(defun nthcdr (idx lst)
  (when lst
    (if (= 0 idx)
        lst
        (nthcdr (1- idx) (cdr lst)))))

(define-test "NTHCDR basically works"
  ((nthcdr 1 '(1 2 3 4)))
  '(2 3 4))
