(fn ancestor-or-self-if (x pred)
  (while x nil
    (& (~> pred x)
       (return x))
    (= x x.parent-node)))

(fn ancestor-or-self? (x elm)
  (ancestor-or-self-if x [eq _ elm]))

(fn ancestors-or-self-if (x pred)
  (with-queue elms
    (while x (queue-list elms)
      (& (~> pred x)
         (enqueue elms x))
      (= x x.parent-node))))
