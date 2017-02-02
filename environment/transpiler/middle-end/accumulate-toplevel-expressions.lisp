(fn add-toplevel-expression (x)
  (push (copy-tree x) (accumulated-toplevel-expressions)))

(fn accumulate-toplevel-expressions (x)
   (remove-if #'not
              (@ [| (named-lambda? _)
                    (%var? _)
                    (& (add-toplevel-expression _)
                       nil)]
                 x)))
