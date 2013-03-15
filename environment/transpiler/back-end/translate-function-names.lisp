;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defun translate-function-name (tr x)
  (? (transpiler-defined-function tr x)
     (compiled-function-name tr x)
     x))

(define-tree-filter translate-function-names (tr fi x) ; XXX use metacode-walker instead
  (named-lambda? x)          (copy-lambda x :body (translate-function-names tr (get-lambda-funinfo x) (lambda-body x)))
  (| (%quote? x)
     (%transpiler-native? x)
     (%%closure? x)
     (%setq-atom-value? x)
     (%function-prologue? x)
     (%function-epilogue? x)
     (& (transpiler-raw-constructor-names? tr)
        (%new? x)))          x
  (%slot-value? x)           `(%slot-value ,(translate-function-name tr .x.) ,..x.)
  (& (atom x)
     (| (not (funinfo-parent fi))
        (not (funinfo-arg-or-var? fi x))))
	                         (translate-function-name tr x))
