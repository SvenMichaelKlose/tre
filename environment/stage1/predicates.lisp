;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2005-2006,2008 Sven Klose <pixel@copei.de>
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
  "Tests on end of a list (NIL)."
  (eq x nil))

(defun symbolp (x)
  "Tests if variable points to itself."
  (and (atom x)
	   (not (symbol-function x))
	   (eq x (symbol-value x))))

(defun variablep (x)
  (and (atom x)
	   (not (or (stringp x)
				(numberp x)))))

(defun keywordp (x)
  "Tests if symbol is in the keyword package."
  (and (atom x)
	   (eq (symbol-package x)
		   *keyword-package*)))

(define-test "NOT works with NIL"
  ((not nil))
  t)

(define-test "NOT works with T"
  ((not t))
  nil)
~
~
