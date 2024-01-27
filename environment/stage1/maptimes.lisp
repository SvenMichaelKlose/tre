(fn maptimes (fun num)
  (with-queue q
    (dotimes (i num (queue-list q))
      (enqueue q (~> fun i)))))

(macro @n (&rest x) ; TODO: Make fun if compiler can track.
  `(maptimes ,@x))
