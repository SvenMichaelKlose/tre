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
