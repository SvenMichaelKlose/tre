;;;;; TRE environment
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defmacro compose (&rest function-list)
  "Combine functions into one. All with one argument."
  (with (rec #'((l)
				  `(,l.
					   ,(if .l
				   			(rec .l)
				   			'x))))
    `#'((x)
		  ,(rec function-list))))

;(define-test "COMPOSE"
;  ((compose a b))
;  #'((x) (a (b x))))
