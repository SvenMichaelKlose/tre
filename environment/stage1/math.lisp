;;;; TRE environment
;;;; Copyright (c) 2005,2009 Sven Klose <pixel@copei.de>
;;;;
;;;; Increment/decrement

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
