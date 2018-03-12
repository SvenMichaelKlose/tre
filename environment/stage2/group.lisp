(functional copy-head group)

(fn copy-head (x size)
  (? (& x (< 0 size))
     (. x. (copy-head .x (-- size)))))

(fn group (x size)
  (with-queue q
    (while x (queue-list q)
       (enqueue q (copy-head x size))
       (= x (nthcdr size x)))))
