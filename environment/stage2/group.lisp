(functional group)

(fn group (x size)
  (with-queue q
    (while x (queue-list q)
       (enqueue q (list-subseq x 0 size))
       (= x (nthcdr size x)))))
