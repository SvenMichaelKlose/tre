;;;;; TRE transpiler
;;;;; Copyright (c) 2009-2011 Sven Klose <pixel@copei.de>

(defun transpiler-update-funinfo-lambda (x)
  (with (fi		  (get-lambda-funinfo x)
		 body	  (lambda-body x)
         num-tags (count-if #'number? body))
    (when (funinfo-num-tags fi)
	  (print fi)
	  (error "funfinfo ~A: num-tags already set to ~A. new num:~A"
		     (lambda-funinfo x) (funinfo-num-tags fi) num-tags))
    (setf (funinfo-num-tags fi) num-tags)
	(copy-lambda x :body (transpiler-update-funinfo body))))

(define-tree-filter transpiler-update-funinfo (x)
  (lambda? x)
    (transpiler-update-funinfo-lambda x))
