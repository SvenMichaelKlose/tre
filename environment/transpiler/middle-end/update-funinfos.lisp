;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defun transpiler-update-funinfo-lambda (x)
  (with (fi		  (get-lambda-funinfo x)
		 body	  (lambda-body x)
         num-tags (count-if #'number? body))
    (when (and (not *recompiling?*)
               (funinfo-num-tags fi))
	  (print fi)
	  (error "funfinfo ~A: num-tags already set to ~A. new num:~A"
		     (lambda-funinfo x) (funinfo-num-tags fi) num-tags))
    (= (funinfo-num-tags fi) num-tags)
	(copy-lambda x :body (transpiler-update-funinfo body))))

(define-tree-filter transpiler-update-funinfo (x)
  (lambda? x) (transpiler-update-funinfo-lambda x))
