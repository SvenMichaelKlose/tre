(functional count)

(%defun count-if (pred lst &optional (init 0))
  (? lst
     (count-if pred .lst (? (apply pred (list lst.))
                            (+ 1 init)
                            init))
     init))

(%defun count (x lst &optional (init 0))
  (count-if #'((i)
                (eq i x))
            lst init))
