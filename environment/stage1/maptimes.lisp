(fn maptimes (fun num)
  (with-queue q
    (dotimes (i num (queue-list q))
      (enqueue q (~> fun i)))))
