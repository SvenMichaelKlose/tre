;;;;; tré - Copyright (c) 2008-2009,2012 Sven Michael Klose <pixel@copei.de>

(defun mapatree (fun x)
  (? (atom x)
     (? x
  	    (funcall fun x)
	    x)
     (cons (mapatree fun x.)
		   (mapatree fun .x))))
