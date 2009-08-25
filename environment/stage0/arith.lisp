;;;; TRE environment
;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

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

;tredoc
; (arg :type (number string)
;  	   :occurence rest)
; "Adds numbers or concatenated strings."
; (returns :type (number string))
(%set-atom-fun +
  #'((&rest x)
	   (if (stringp (car x))
		   (apply #'string-concat x)
		   (apply #'number+ x))))

;; NUMBER- should be NON-CHARACTER-
;tredoc
; (arg :type number)
; "Substract rest of arguments from first."
; (returns :type number)
(%set-atom-fun -
  #'((&rest x)
	   (apply #'number- x)))
