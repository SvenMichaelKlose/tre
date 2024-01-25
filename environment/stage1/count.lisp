(functional count)

(fn count-if (pred lst &optional (init 0))
  (? lst
     (count-if pred .lst (? (*> pred (… lst.))
                            (+ 1 init)
                            init))
     init))

(fn count (x lst &optional (init 0) &key (test #'eql))
  (count-if [apply test _ (… x)] lst init))
