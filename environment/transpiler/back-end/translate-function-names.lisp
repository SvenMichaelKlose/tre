;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun translate-function-name (funinf x)
  (if (and (transpiler-defined-function *current-transpiler* x)
		   (or (not funinf)
			   (not (funinfo-in-env-or-lexical? funinf x))))
	  (compiled-function-name x)
	  x))

(define-tree-filter translate-function-names (funinf x)
  (named-lambda? x)
	(copy-lambda x
				 :name (compiled-function-name (second x))
				 :body (translate-function-names (get-lambda-funinfo x)
						   						 (lambda-body x)))
  (lambda? x)
	(copy-lambda x
				 :body (translate-function-names (get-lambda-funinfo x)
						   						 (lambda-body x)))
  (or (%quote? x)
	  (%transpiler-native? x)
	  (%%funref? x)
	  (%setq-atom-value? x))
	x
  (%slot-value? x)
	`(%slot-value ,(translate-function-name funinf (second x))
				  ,(third x))
  (atom x)
	(translate-function-name funinf x))
