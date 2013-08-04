;;;;; tré – Copyright (c) 2005,2009,2011,2013 Sven Michael Klose <pixel@copei.de>

(functional ++ -- integer++ integer--)

(early-defun ++ (x)
  (number+ x 1))

(define-test "++"
  ((++ 1))
  2)

(early-defun -- (x)
  (number- x 1))

(define-test "--"
  ((-- 2))
  1)

(early-defun integer++ (x)
  (integer+ x 1))

(early-defun integer-- (x)
  (integer- x 1))


(defmacro 1+ (x)
  (%error "1+ is deprecated."))

(defmacro 1- (x)
  (%error "1- is deprecated."))

(defmacro integer-1+ (x)
  (%error "integer-1+ is deprecated."))

(defmacro integer-1- (x)
  (%error "integer-1- is deprecated."))
