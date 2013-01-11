;;;;; tré – Copyright (c) 2009,2011–2013 Sven Michael Klose <pixel@copei.de>

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
       (#'((a)
             (? a
                (apply (?
                         (cons? a)   #'append
                         (string? a) #'string-concat
                         #'number+)
                       x)
                (? (cdr x)
                   (apply #'+ (cdr x)))))
            (car x))))

(%set-atom-fun -
  #'((&rest x)
	   (apply #'number- x)))
