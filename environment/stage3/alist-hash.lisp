(functional alist-hash hash-alist)

(fn alist-hash (x &key (test #'eql))
  (let h (make-hash-table :test test)
    (@ (i x h)
      (= (href h i.) .i))))

(fn hash-alist (x)
  (@ [. _ (href x _)]
     (hashkeys x)))
