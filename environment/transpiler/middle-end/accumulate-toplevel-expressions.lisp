(fn accumulate-toplevel-expressions (x)
   (remove-if #'not
              (@ [| (named-lambda? _)
                    (%var? _)
                    (& (add-toplevel-expression _)
                       nil)]
                 x)))
