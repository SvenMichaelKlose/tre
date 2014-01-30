;;;;; tré – Copyright (c) 2005–2009,2012 Sven Michael Klose <pixel@copei.de>

(defmacro with-cons (a d c &body body)
  `(when ,c
	 (with (,a (car ,c)
            ,d (cdr ,c))
       ,@body)))
