;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defun string-concat (&rest x) x (apply #'concatenate 'string x))

(defun %string (x)
  (? (numberp x)
     (format nil "~A" x)
     (string x)))

(defun string== (a b) (string= a b))

(defun list-string (x)
  (apply #'concatenate 'string (mapcar #'(lambda (x)
                                           (string (? (numberp x)
                                                      (code-char x)
                                                      x)))
                                       x)))
