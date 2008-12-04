;;;; TRE environment
;;;; Copyright (C) 2006,2008 Sven Klose <pixel@copei.de>

(defmacro with-gensym (q &rest body)
  `(let* (,@(mapcar #'((x) `(,x (gensym))) 
		            (if (consp q)
					    q
					    (list q))))
     ,@body))

; XXX tests missing
