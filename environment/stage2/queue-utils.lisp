;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Queue utilities

(defmacro with-queue (q &rest body)
  `(let (,@(mapcar #'(lambda (x) `(,x (make-queue))) 
		   (if (consp q) q (list q))))
     ,@body))

(defmacro dolist-queue (q dlargs &rest body)
  `(with-queue ,q
     (dolist ,(append dlargs `((queue-list ,q)))
       ,@body)))
