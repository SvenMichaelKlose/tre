; tré – Copyright (c) 2010–2015 Sven Michael Klose <pixel@copei.de>

(defun translate-function-name (x)
  (? (defined-function x)
     (compiled-function-name x)
     x))

(defun nontranslatable-name? (x)
  (| (quote? x)
     (%%native? x)
     (%%closure? x)
     (%function-prologue? x)
     (%function-epilogue? x)
     (%new? x)))

(define-tree-filter translate-function-names-0 (fi x)
  (named-lambda? x)          (copy-lambda x :body (translate-function-names-0 (get-lambda-funinfo x) (lambda-body x)))
  (nontranslatable-name? x)  x
  (%slot-value? x)           `(%slot-value ,(translate-function-name .x.) ,..x.)
  (& (atom x)
     (| (not (funinfo-parent fi))
        (not (funinfo-arg-or-var? fi x))))  (translate-function-name x))

(defun translate-function-names (x)
  (? (function-name-prefix)
     (translate-function-names-0 (global-funinfo) x)
     x))

