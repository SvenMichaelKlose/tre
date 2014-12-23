;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun %make-hash-table (&key (test #'eql))
  (cl:make-hash-table :test (?
                           (eq test #'eq)       #'cl:eq
                           (or (eq test #'eql)
                               (eq test #'==))  #'cl:eql
                           test)))

(defun hash-table? (x) (cl:hash-table-p x))
(defun href (x i) (cl:gethash i x))
(defun =-href (v x i) (cl:setf (cl:gethash i x) v))
(defun hremove (x k) (cl:remhash k x))

(defun copy-hash-table (x)
  (aprog1 (cl:make-hash-table :test (cl:hash-table-test x)
                              :size (cl:hash-table-size x))
    (cl:maphash #'(lambda (k v)
                    (cl:setf (cl:gethash k n) v))
             x)))

(defun hashkeys (x)
  (aprog1 nil
    (cl:maphash #'(lambda (k v)
                    v
                    (cl:push k !))
             x)))
