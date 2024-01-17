(fn pad-0 (seq p)
  (!? seq
      (. !.  (& .!
                (. p (pad .! p))))))

(fn pad (seq p) ; TODO: Reverse arguments.
  (? (& (atom seq)
        (not (array? seq)))
     seq
     (pad-0 (?
              (cons? seq)  seq
              (array? seq) (array-list seq)
              seq)
            p)))
