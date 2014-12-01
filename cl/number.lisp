;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defun %number? (x)
  (or (numberp x)
      (characterp x)))

(defun %integer (x)
  (floor x))

(defun chars-to-numbers (x)
  (mapcar #'(lambda (x)
              (? (characterp x)
                 (char-code x)
                 x))
          x))

(defun == (&rest x) (apply #'= (chars-to-numbers x)))
(defun number== (&rest x) (apply #'= (chars-to-numbers x)))
(defun integer== (&rest x) (apply #'= (chars-to-numbers x)))
(defun character== (&rest x) (apply #'= (chars-to-numbers x)))
(defun %+ (&rest x) (apply #'+ (chars-to-numbers x)))
(defun %- (&rest x) (apply #'- (chars-to-numbers x)))
(defun %* (&rest x) (apply #'* (chars-to-numbers x)))
(defun %/ (&rest x) (apply #'/ (chars-to-numbers x)))
(defun %< (&rest x) (apply #'< (chars-to-numbers x)))
(defun %> (&rest x) (apply #'> (chars-to-numbers x)))

(defun bit-or (a b) (bit-or a b))
