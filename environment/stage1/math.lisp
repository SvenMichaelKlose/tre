;;;;; tré – Copyright (c) 2005,2009,2011,2013 Sven Michael Klose <pixel@copei.de>

(functional ++ -- integer++ integer--)

(early-defun ++ (x)
  (number+ x 1))

(early-defun -- (x)
  (number- x 1))

(early-defun integer++ (x)
  (integer+ x 1))

(early-defun integer-- (x)
  (integer- x 1))

(define-test "++"
  ((++ 1))
  2)

(define-test "--"
  ((-- 2))
  1)
