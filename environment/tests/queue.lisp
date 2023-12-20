(deftest "ENQUEUE and QUEUE-LIST work"
  ((with-queue q
     (enqueue q 'a)
     (enqueue q 'b)
     (queue-list q)))
  '(a b))
