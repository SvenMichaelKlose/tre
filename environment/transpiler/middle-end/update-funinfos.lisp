;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(define-tree-filter transpiler-update-funinfo (x)
  (named-lambda? x)
      (with (fi		  (get-lambda-funinfo x)
		     body	  (lambda-body x)
             num-tags (count-if #'number? body))
        (& (not *recompiling?*)
           (funinfo-num-tags fi)
	       (error "funfinfo ~A: num-tags already set to ~A. new num:~A" fi (funinfo-num-tags fi) num-tags))
        (= (funinfo-num-tags fi) num-tags)
	    (copy-lambda x :body (transpiler-update-funinfo body))))
