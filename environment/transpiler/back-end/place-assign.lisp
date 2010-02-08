;;;;; TRE compiler
;;;;; Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>

(metacode-walker place-assign (x)
	:if-atom		x
	:if-stack		`(%stack ,(funinfo-env-pos (get-lambda-funinfo-by-sym .x.) ..x.))
	:if-vec			`(%vec ,(place-assign .x.)
			   			   ,(or (funinfo-lexical-pos (get-lambda-funinfo-by-sym ..x.)
										 			 ...x.)
								(error "can't find index in lexicals")))
	:if-lambda		`#'(,@(lambda-head x)
		     				,@(place-assign (lambda-body x)))

    :if-slot-value	`(%slot-value ,(place-assign .x.)
								  ,..x.))
