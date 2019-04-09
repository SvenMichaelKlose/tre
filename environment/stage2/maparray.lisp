(fn maparray (fun hash)
  (with-queue q
    (dotimes (i (length hash) (queue-list q))
      (enqueue q (funcall fun (aref hash i))))))
