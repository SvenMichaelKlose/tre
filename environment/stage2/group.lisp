(functional group)

(fn group (x size)
  (when x
    (. (list-subseq x 0 size)
       (group (nthcdr size x) size))))
