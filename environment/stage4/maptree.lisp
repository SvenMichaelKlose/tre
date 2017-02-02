(fn maptree (fun x)
  (? (atom x)
     (funcall fun x)
     (@ [? (cons? _)
           (funcall fun (maptree fun (funcall fun _)))  ; TODO: Redux.
           (funcall fun _)]
        x)))
