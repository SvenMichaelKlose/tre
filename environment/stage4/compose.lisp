(defmacro compose (&rest function-list)
  (with (rec #'((l)
				  `(,(alet l.
                       (? (& (cons? !)
                             (eq 'function !.)
                             (atom .!.))
                          .!.
                          !))
					   ,(? .l
				   		   (rec .l)
				   		   'x))))
    `#'((x)
		  ,(rec function-list))))
