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
       (apply (?
                (string? (car x)) #'string-concat
                (not (car x)) #'append
                (cons? (car x)) #'append
                #'number+)
              x)))

(%set-atom-fun -
  #'((&rest x)
	   (apply #'number- x)))
