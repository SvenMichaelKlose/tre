; tré – Copyright (c) 2008–2013,2015–2016 Sven Michael Klose <pixel@copei.de>

(defvar *js-array-constructor* (make-array).constructor)

(defun aref (a k)     (%%%aref a k))
(defun =-aref (v a k) (%%%=-aref v a k))
(defmacro aref (a k)     `(%%%aref ,a ,k))
(defmacro =-aref (v a k) `(%%%=-aref ,v ,a ,k))

(defun array? (x)
  (& x (eq *js-array-constructor* x.constructor)))

(defun list-array (x)
  (alet (make-array)
    (@ (i x !)
      (!.push i))))

(defun array-find (arr obj)     ; TODO: Move to application that uses it.
  (not (== -1 (arr.index-of obj))))
