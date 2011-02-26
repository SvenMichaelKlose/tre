;;;;; TRE transpiler
;;;;; Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

(defun translate-function-name (funinf x)
  (if (and (transpiler-defined-function *current-transpiler* x)
		   (or (not funinf)
			   (not (funinfo-in-env-or-lexical? funinf x))))
	  (compiled-function-name x)
	  x))

(define-tree-filter translate-function-names (tr funinf x)
  (named-lambda? x)
	(copy-lambda x :name (compiled-function-name .x.)
				   :body (translate-function-names tr (get-lambda-funinfo x) (lambda-body x)))
  (lambda? x)
	(copy-lambda x :body (translate-function-names tr (get-lambda-funinfo x) (lambda-body x)))
  (or (%quote? x)
	  (%transpiler-native? x)
	  (%%funref? x)
	  (%setq-atom-value? x))
	x
  (%slot-value? x)
	`(%slot-value ,(translate-function-name funinf .x.) ,..x.)
  (and (transpiler-raw-constructor-names? tr)
       (%new? x))
    `(%new ,@.x)
  (atom x)
	(translate-function-name funinf x))
