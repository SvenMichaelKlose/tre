;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Local recursive functions

(defmacro labels (fdefs &rest main-body)
  (let* ((fn (first fdefs))
	 (name (first fn))
	 (args (second fn))
	 (body (cddr fn)))
    `(let ((,name))
       (%set-atom-fun ,name
	 #'(,args
	     (block ,name
	       ,@body)))
       ,@(if (cdr fdefs)
	   `((labels ,(cdr fdefs)
	       ,@main-body))
	   main-body))))
