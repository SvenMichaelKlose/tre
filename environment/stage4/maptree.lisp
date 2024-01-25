(fn maptree (fun x)
  (? (atom x)
     (~> fun x)
     (@ [? (cons? _)
           (~> fun (maptree fun (~> fun _)))  ; TODO: Redux.
           (~> fun _)]
        x)))
