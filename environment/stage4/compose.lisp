;;;;; tré – Copyright (c) 2008–2009,2012–2014 Sven Michael Klose <pixel@copei.de>

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
