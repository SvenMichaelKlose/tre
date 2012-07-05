;;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defun copy-lambda-name (x name)
  (!? (get-lambda-funinfo x)
      (= (funinfo-name !) name))
  name)

(defun copy-lambda (x &key (name nil) (info nil) (args 'no-args) (body 'no-bpdy))
  `(function
	 ,@(awhen (!? name
				  (copy-lambda-name x !)
				  (lambda-name x))
		 (list !))
	 (,@(? info
		   (make-lambda-funinfo-if-missing x info)
		   (lambda-funinfo-expr x))
	  ,(? (eq 'no-args args)
          (lambda-args x)
          args)
	  ,@(? (eq 'no-body body)
           (lambda-body x)
           body))))
