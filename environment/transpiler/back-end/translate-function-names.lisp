;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defun translate-function-name (funinfo x)
  (? (& (transpiler-defined-function *current-transpiler* x)
	    (| (not funinfo)
	       (not (funinfo-var-or-lexical? funinfo x))))
     (compiled-function-name *current-transpiler* x)
     x))

(define-tree-filter translate-function-names (tr funinfo x)
  (named-lambda? x)
	(copy-lambda x :name (compiled-function-name tr .x.)
				   :body (translate-function-names tr (get-lambda-funinfo x) (lambda-body x)))
  (lambda? x)
	(copy-lambda x :body (translate-function-names tr (get-lambda-funinfo x) (lambda-body x)))
  (| (%quote? x)
     (%transpiler-native? x)
     (%%closure? x)
     (%setq-atom-value? x))
	x
  (%slot-value? x)
	`(%slot-value ,(translate-function-name funinfo .x.) ,..x.)
  (& (transpiler-raw-constructor-names? tr)
     (%new? x))
    x
  (atom x)
	(translate-function-name funinfo x))
