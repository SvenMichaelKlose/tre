;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(defun translate-function-name (funinf x)
  (? (& (transpiler-defined-function *current-transpiler* x)
	    (| (not funinf)
	       (not (funinfo-in-env-or-lexical? funinf x))))
     (compiled-function-name *current-transpiler* x)
     x))

(define-tree-filter translate-function-names (tr funinf x)
  (named-lambda? x)
	(copy-lambda x :name (compiled-function-name tr .x.)
				   :body (translate-function-names tr (get-lambda-funinfo x) (lambda-body x)))
  (lambda? x)
	(copy-lambda x :body (translate-function-names tr (get-lambda-funinfo x) (lambda-body x)))
  (| (%quote? x)
     (%transpiler-native? x)
     (%%funref? x)
     (%setq-atom-value? x))
	x
  (%slot-value? x)
	`(%slot-value ,(translate-function-name funinf .x.) ,..x.)
  (& (transpiler-raw-constructor-names? tr)
     (%new? x))
    x
  (atom x)
	(translate-function-name funinf x))
