;;;;; TRE environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun mapatree (fun x)
  (if (atom x)
      (if x
	  	  (funcall fun x)
		  x)
	  (cons (mapatree fun (car x))
			(mapatree fun (cdr x)))))
