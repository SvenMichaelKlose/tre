(fn translate-function-name (x)
  (? (defined-function x)
     (compiled-function-name x)
     x))

(define-tree-filter translate-function-names (x &optional (fi (global-funinfo)))
  (named-lambda? x)
    (copy-lambda x :body (translate-function-names (lambda-body x)
                                                   (lambda-funinfo x)))
  (| (quote? x)
     (%native? x)
     (%closure? x)
     (%function-prologue? x)
     (%function-epilogue? x)
     (%new? x))
    x
  (%slot-value? x)
    `(%slot-value ,(translate-function-name .x.) ,..x.)
  (%collection? x)
    `(%collection ,.x.
       ,@(@ [. _. (translate-function-names ._ fi)] ..x))
  (& (atom x)
     (| (not (funinfo-parent fi))
        (not (funinfo-arg-or-var? fi x))))
    (translate-function-name x))

; TODO: This one is messing up %CLOSUREs.
;(metacode-walker translate-function-names (x)
;  :if-cons
;      (list (translate-function-names-in-tree x.)))
