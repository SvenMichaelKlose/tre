;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defun translate-function-name (tr funinfo x)
  (? (transpiler-defined-function tr x)
     (compiled-function-name tr x)
     x))

(define-tree-filter translate-function-names (tr funinfo x) ; XXX use metacode-walker instead
  (named-lambda? x)          (copy-lambda x :name (compiled-function-name tr .x.)
				                            :body (translate-function-names tr (get-lambda-funinfo x) (lambda-body x)))
  (lambda? x)                (copy-lambda x :body (translate-function-names tr (get-lambda-funinfo x) (lambda-body x)))
  (| (%quote? x)
     (%transpiler-native? x)
     (%%closure? x)
     (%setq-atom-value? x))  x
  (%slot-value? x)           `(%slot-value ,(translate-function-name tr funinfo .x.) ,..x.)
  (& (transpiler-raw-constructor-names? tr)
     (%new? x))              x
  (& (atom x)
     (| (not (funinfo-parent funinfo))
        (not (funinfo-arg-or-var? funinfo x))))
	                         (translate-function-name tr funinfo x))
