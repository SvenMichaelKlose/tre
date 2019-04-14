(fn count-if (pred lst &optional (init 0))
  (? lst
     (count-if pred .lst (? (apply pred (list lst.))
                            (+ 1 init)
                            init))
     init))

(functional count)
(fn count (x lst &optional (init 0) &key (test #'eql))
  (count-if #'((i)
                (apply test i (list x)))
            lst init))
