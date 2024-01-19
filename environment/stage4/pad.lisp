(fn pad (seq p)
  (with (rec [. _. (& ._ (. p (rec ._)))])
    (?
      (array? seq)  (list-array (rec (array-list seq)))
      (atom seq)    seq
      (rec seq))))
