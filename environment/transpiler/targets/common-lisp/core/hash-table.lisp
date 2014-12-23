;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defun %make-hash-table (&key (test #'eql))
  (make-hash-table :test (?
                           (eq test #'tre:eq)       #'eq
                           (or (eq test #'tre:eql)
                               (eq test #'==))      #'eql
                           test)))

(defun hash-table? (x) (hash-table-p x))
(defun href (x i) (gethash i x))
(defun =-href (v x i) (setf (gethash i x) v))
(defun hremove (x k) (remhash k x))

(defun copy-hash-table (x)
  (let ((n (make-hash-table :test (hash-table-test x)
                            :size (hash-table-size x))))
    (maphash #'(lambda (k v)
                 (setf (gethash k n) v))
             x)
    n))

(defun hashkeys (x)
  (let ((n nil))
    (maphash #'(lambda (k v)
                 v
                 (push k n))
             x)
    n))
