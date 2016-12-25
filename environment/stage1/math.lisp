; tré – Copyright (c) 2005,2009,2011,2013–2014,2016 Sven Michael Klose <pixel@hugbox.org>

(functional ++ -- integer++ integer--)

(%defun ++ (x) (number+ x 1))
(%defun -- (x) (number- x 1))
(%defun integer++ (x) (integer+ x 1))
(%defun integer-- (x) (integer- x 1))

(define-test "++"
  ((++ 1))
  2)

(define-test "--"
  ((-- 2))
  1)
