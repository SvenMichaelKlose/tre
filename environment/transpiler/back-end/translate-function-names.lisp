;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun translate-function-name (x funinf)
  (if (and (transpiler-defined-function *current-transpiler* x)
		   (or (not funinf)
			   (not (funinfo-in-env-or-lexical? funinf x))))
	  (compiled-function-name x)
	  x))

(defun translate-function-names (x &optional (funinf nil))
  (if
	(named-function-expr? x)
	  (copy-lambda x
				   :name (compiled-function-name (second x))
				   :body (translate-function-names (lambda-body x)
												   (get-lambda-funinfo x)))
	(lambda? x)
	  (copy-lambda x
				   :body (translate-function-names (lambda-body x)
												   (get-lambda-funinfo x)))
	(or (%quote? x)
		(%transpiler-native? x)
		(%%funref? x)
		(%setq-atom-value? x))
	  x
	(%slot-value? x)
	  `(%slot-value ,(translate-function-name (second x) funinf)
					,(third x))
	(consp x)
	  (cons (translate-function-names x. funinf)
	  		(translate-function-names .x funinf))

	(translate-function-name x funinf)))
