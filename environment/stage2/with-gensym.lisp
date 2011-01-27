;;;; TRE environment
;;;; Copyright (c) 2006,2008,2011 Sven Klose <pixel@copei.de>

(defmacro with-gensym (q &rest body)
  `(let* (,@(mapcar #'((x) `(,x (gensym))) 
		            (force-list q)))
     ,@body))

; XXX tests missing
