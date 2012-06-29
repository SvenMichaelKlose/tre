;;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defun copy-lambda-name (x name)
  (!? (get-lambda-funinfo x)
      (= (funinfo-name !) name))
  name)

(defun copy-lambda (x &key (name nil) (info nil) (args nil) (body nil))
  `(function
	 ,@(awhen (!? name
				  (copy-lambda-name x !)
				  (lambda-name x))
		 (list !))
	 (,@(? info
		   (make-lambda-funinfo-if-missing x info)
		   (lambda-funinfo-expr x))
	  ,(| args (lambda-args x))
	  ,@(| body (lambda-body x)))))
