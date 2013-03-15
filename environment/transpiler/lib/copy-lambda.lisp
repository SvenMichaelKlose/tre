;;;;; tré – Copyright (c) 2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun copy-lambda (x &key (name nil) (args 'no-args) (body 'no-body))
  `(function
	 ,@(!? (| name (lambda-name x))
		   (list !))
	 (,(? (eq 'no-args args)
          (lambda-args x)
          args)
	  ,@(? (eq 'no-body body)
           (lambda-body x)
           body))))
