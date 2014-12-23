;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun number? (x)
  (| (cl:numberp x)
     (cl:characterp x)))

(defun integer (x)
  (cl:floor x))

(defun chars-to-numbers (x)
  (cl:mapcar #'(lambda (x)
                 (? (cl:characterp x)
                    (cl:char-code x)
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

(defun bit-or (a b) (cl:bit-or a b))
