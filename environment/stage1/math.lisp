;;;; TRE environment
;;;; Copyright (c) 2005,2009,2011 Sven Klose <pixel@copei.de>

(functional 1+ 1- integer-1+ integer-1-)

(%defun 1+ (x)
  (number+ x 1))

(define-test "1+"
  ((1+ 1))
  2)

(%defun 1- (x)
  (number- x 1))

(define-test "1-"
  ((1- 2))
  1)

(%defun integer-1+ (x)
  (integer+ x 1))

(%defun integer-1- (x)
  (integer- x 1))
