;;;; TRE environment
;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(setq *universe* (cons '+ *universe*))

(%set-atom-fun +
  #'((&rest x)
	   (if (stringp (car x))
		   (apply #'string-concat x)
		   (apply #'number+ x))))

;; NUMBER- should be NON-CHARACTER-
(%set-atom-fun -
  #'((&rest x)
	   (apply #'number- x)))
