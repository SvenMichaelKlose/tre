(fn translate-function-name (x)
  (? (defined-function x)
     (compiled-function-name x)
     x))

(define-tree-filter translate-function-names (x)
  (named-lambda? x)
    (do-lambda x
      :body (translate-function-names (lambda-body x)))
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
       ,@(@ [. '%inhibit-macro-expansion
               (. ._. (translate-function-names .._))]
            ..x))
  (& (atom x)
     (| (not (funinfo-parent *funinfo*))
        (not (funinfo-arg-or-var? *funinfo* x))))
    (translate-function-name x))
