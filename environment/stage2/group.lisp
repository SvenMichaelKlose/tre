(functional copy-head group)

(fn copy-head (x size)
  (? (& x (< 0 size))
     (. x. (copy-head .x (-- size)))))

(fn group (x size)
  (& x
     (. (copy-head x size)
        (group (nthcdr size x) size))))
