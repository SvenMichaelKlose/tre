;;;; TRE environment
;;;; Copyright (C) 2005-2006,2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Local recursive functions

(defmacro labels (fdefs &rest main-body)
  (let* ((fun (first fdefs))
	     (name (first fun))
	     (args (second fun))
	     (body (cddr fun)))
    `(let ,name nil
       (%set-atom-fun ,name
	     #'(,args
	         (block ,name
	           ,@body)))
       ,@(if (cdr fdefs)
	         `((labels ,(cdr fdefs)
	             ,@main-body))
	         main-body))))
