;;;; TRE environment
;;;; Copyright (C) 2005-2009 Sven Klose <pixel@copei.de>

(defmacro with-cons (a d c &rest body)
  `(when ,c
	 (with (,a (car ,c)
            ,d (cdr ,c))
       ,@body)))
