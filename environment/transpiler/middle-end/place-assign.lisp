;;;;; TRE compiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun place-assign (x)
  (if
	(or (atom x)
		(%quote? x)
		(%transpiler-native? x))
	  x

	(and (%stack? x)
		 ..x)
		`(%stack ,(funinfo-env-pos (get-lambda-funinfo-by-sym .x.) ..x.))

	(and (%vec? x)
		 ...x)
		`(%vec ,(place-assign .x.)
			   ,(or (funinfo-lexical-pos (get-lambda-funinfo-by-sym ..x.)
										 ...x.)
					(error "can't find index in lexicals")))

	(lambda? x) ; XXX Add variables to ignore in subfunctions.
      `#'(,@(lambda-funinfo-and-args x)
		     ,@(place-assign (lambda-body x)))

    (%slot-value? x)
      `(%slot-value ,(place-assign .x.)
					,..x.)

    (cons (place-assign x.)
		  (place-assign .x))))
