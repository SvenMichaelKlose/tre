(fn collect-places (x)
  (@ [?
       (named-lambda? _)
         (with-lambda-funinfo _
           (let fi *funinfo*
             (!? (funinfo-scope fi)
                 (= (funinfo-used-vars fi) (list !)))
             (= (funinfo-places fi) nil)
             (collect-places (lambda-body _))))
       (%%go-cond? _)
         (funinfo-add-used-var *funinfo* (%%go-value _))
       (%=? _)
         (let fi *funinfo*
           (with-%= p v _
             (funinfo-add-place fi p)
             (funinfo-add-used-var fi p)
             (@ (i (ensure-list v))
               (funinfo-add-used-var fi i))))]
     x)
  x)
