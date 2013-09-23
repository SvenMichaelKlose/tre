;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(define-tree-filter update-funinfo-num-tags (x)
  (named-lambda? x)
      (with (fi		  (get-lambda-funinfo x)
		     body	  (lambda-body x)
             num-tags (count-if #'number? body))
        (& (not *recompiling?*)
           (funinfo-num-tags fi)
	       (error "FUNFINO ~A: NUM-TAGS already set to ~A. Can't set new number ~A." fi (funinfo-num-tags fi) num-tags))
        (= (funinfo-num-tags fi) num-tags)
	    (copy-lambda x :body (update-funinfo-num-tags body))))
