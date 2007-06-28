;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Comparison

(defun equal (x y)
  "Return T if arguments are the same or have the same value."
  (if (or (atom x) (atom y))
    (eql x y)
    (if (equal (car x) (car y))
      (equal (cdr x) (cdr y)))))

(define-test "EQUAL fails on different lists"
  ((equal '(1 2) '(3 4)))
  nil)

(defun >= (x y)
  (or (= x y)
      (> x y)))

(defun <= (x y)
  (or (= x y)
      (< x y)))

(defun neql (&rest args)
  "Return (not (eql ...)."
  (not (apply #'eql args)))
