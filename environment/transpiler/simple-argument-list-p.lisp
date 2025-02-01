(fn simple-argument-list? (x)
  (? x
     (notany [| (cons? _)
                (argument-keyword? _)]
             x)
     t))
