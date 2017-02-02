(fn alist-hash (x &key (test #'eql))
  (let h (make-hash-table :test test)
    (@ (i x h)
      (= (href h i.) .i))))

(fn hash-alist (x)
  (with-queue alist
    (@ (i (hashkeys x) (queue-list alist))
      (enqueue alist (. i (href x i))))))
