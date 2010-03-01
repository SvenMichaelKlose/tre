;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun copy-lambda-name (x name)
  (awhen (get-lambda-funinfo x)
    (setf (funinfo-name !) name))
  name)

(defun copy-lambda (x &key (name nil)
					  	   (info nil)
						   (args nil)
						   (body nil))
  `(function
	 ,@(awhen (aif name
				   (copy-lambda-name x !)
				   (lambda-name x))
		 (list !))
	 (,@(if info
		    (make-lambda-funinfo-if-missing x info)
		    (lambda-funinfo-expr x))
	  ,(or args
		   (lambda-args x))
	  ,@(or body
			(lambda-body x)))))
