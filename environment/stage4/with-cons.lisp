;;;; TRE environment
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>

(defmacro with-cons (a d c &rest body)
  `(let* ((,a (car ,c))
          (,d (cdr ,c)))
     ,@body))
