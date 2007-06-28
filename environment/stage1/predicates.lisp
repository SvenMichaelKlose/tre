;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Predicate functions

(defun zerop (x)
  "Return T if the argument value is 0."
  (eq x 0))

(defun evenp (x)
  "Return T if x is an even number."
  (= 0 (mod x 2)))

(defun null (x)
  "Return T if argument is non-atomic."
  (listp x))

(defun endp (x)
  (eq x nil))

(define-test "NOT works with NIL"
  ((not nil))
  t)

(define-test "NOT works with T"
  ((not t))
  nil)
~
~
