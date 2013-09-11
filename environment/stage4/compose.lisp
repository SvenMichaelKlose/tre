;;;;; tré – Copyright (c) 2008–2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(defmacro compose (&rest function-list)
  (with (rec #'((l)
				  `(,l.
					   ,(? .l
				   		   (rec .l)
				   		   'x))))
    `#'((x)
		  ,(rec function-list))))
