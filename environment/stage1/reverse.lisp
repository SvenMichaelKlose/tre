;;;;; tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(functional reverse)

(defun reverse (lst)
  (alet nil
    (dolist (i lst !)
      (push i !))))

(define-test "REVERSE works"
  ((reverse '(1 2 3)))
  '(3 2 1))
