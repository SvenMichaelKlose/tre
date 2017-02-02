(fn pad (seq p)
  (!? seq
      (. !.  (& .!
                (. p (pad .! p))))))
