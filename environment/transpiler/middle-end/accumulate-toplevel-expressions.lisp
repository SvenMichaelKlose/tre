(fn accumulate-toplevel-expressions (x)
  (@ [| (named-lambda? _)
        (%var? _)
        (& (add-toplevel-expression _)
           nil)]
     x))
