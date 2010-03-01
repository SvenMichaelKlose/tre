;;;;; TRE transpiler
;;;;; Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>

(defun transpiler-update-funinfo-lambda (x)
  (with (fi		  (get-lambda-funinfo x)
		 body	  (lambda-body x)
         num-tags (count-if #'numberp body))
    (when (funinfo-num-tags fi)
	  (print fi)
	  (error "funfinfo ~A: num-tags already set to ~A. new num:~A"
		     (lambda-funinfo x) (funinfo-num-tags fi) num-tags))
    (setf (funinfo-num-tags fi) num-tags)
	(copy-lambda x
		:body (transpiler-update-funinfo body))))

(defun transpiler-update-funinfo (x)
  (if
	(atom x)	x
	(lambda? x) (transpiler-update-funinfo-lambda x)
	(cons (transpiler-update-funinfo x.)
		  (transpiler-update-funinfo .x))))
