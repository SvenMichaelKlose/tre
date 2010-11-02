;;;; TRE environment
;;;; Copyright (c) 2005-2006,2008 Sven Klose <pixel@copei.de>

(defmacro with-queue (q &rest body)
  `(let* (,@(mapcar #'((x) `(,x (make-queue))) 
		            (if (consp q)
					    q
					    (list q))))
     ,@body))

(defmacro dolist-queue (q dlargs &rest body)
  `(with-queue ,q
     (dolist ,(append dlargs `((queue-list ,q)))
       ,@body)))
