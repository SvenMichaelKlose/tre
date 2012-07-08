;;;;; tré – Copyright (c) 2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(setq
	*universe*
	(cons '+
	(cons '-
		  *universe*)))

(setq
	*defined-functions*
	(cons '+
	(cons '-
		  *defined-functions*)))

(%set-atom-fun +
  #'((&rest x)
       (?
         (string? (car x)) (apply #'string-concat x)
         (cons? (car x)) (apply #'append x)
         (apply #'number+ x))))

(%set-atom-fun -
  #'((&rest x)
	   (apply #'number- x)))
