(fn permutate (&rest x)
  (with (r #'((head tail-permutations)
               (& head
                  (!? tail-permutations
                      (mapcan #'((h)
                                  (@ [. h (copy-list _)] !))
                              head)
                      (@ #'list head)))))
    (& x (r x. (apply #'permutate .x)))))
