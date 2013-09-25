;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defun translate-function-name (x)
  (? (transpiler-defined-function *transpiler* x)
     (compiled-function-name x)
     x))

(defun nontranslatable-name? (x)
  (| (%quote? x)
     (%%native? x)
     (%%closure? x)
     (%function-prologue? x)
     (%function-epilogue? x)
     (& (transpiler-raw-constructor-names? *transpiler*)
        (%new? x))))

(define-tree-filter translate-function-names (fi x) ; XXX use metacode-walker instead
  (named-lambda? x)          (copy-lambda x :body (translate-function-names (get-lambda-funinfo x) (lambda-body x)))
  (nontranslatable-name? x)  x
  (%slot-value? x)           `(%slot-value ,(translate-function-name .x.) ,..x.)
  (& (atom x)
     (| (not (funinfo-parent fi))
        (not (funinfo-arg-or-var? fi x))))
                             (translate-function-name x))
