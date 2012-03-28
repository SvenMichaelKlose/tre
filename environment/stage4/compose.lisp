;;;;; tré - Copyright (c) 2008-2009,2012 Sven Klose <pixel@copei.de>

(defmacro compose (&rest function-list)
  "Combine functions into one. All with one argument."
  (with (rec #'((l)
				  `(,l.
					   ,(? .l
				   		   (rec .l)
				   		   'x))))
    `#'((x)
		  ,(rec function-list))))

;(define-test "COMPOSE"
;  ((compose a b))
;  #'((x) (a (b x))))
