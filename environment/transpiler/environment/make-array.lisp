(fn make-array (&rest dimensions)
  (aprog1 #()
    (dotimes (i dimensions.)
      (= (aref ! i) (!? .dimensions
                        (*> #'make-array !))))))
