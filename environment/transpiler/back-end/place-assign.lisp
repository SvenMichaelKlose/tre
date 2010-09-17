;;;;; TRE compiler
;;;;; Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>

(define-tree-filter place-assign (x)
  (or (%quote? x)
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
  (lambda? x)
    (copy-lambda x :body (place-assign (lambda-body x)))
  (%slot-value? x)
    `(%slot-value ,(place-assign .x.)
				  ,..x.))
