(fn collect-places-r (x)
  (?
    (named-lambda? x.) (with-lambda-funinfo x.
                         (let fi *funinfo*
                           (!? (funinfo-scope fi)
                               (= (funinfo-used-vars fi) (list !)))
                           (= (funinfo-places fi) nil)
                           (collect-places-r (lambda-body x.))))
    (%%go-cond? x.)    (funinfo-add-used-var *funinfo* (%%go-value x.))
    (%=? x.)           (let fi *funinfo*
                         (with-%= p v x.
                           (funinfo-add-place fi p)
                           (funinfo-add-used-var fi p)
                           (@ (i (ensure-list v))
                             (funinfo-add-used-var fi i)))))
  (& x (collect-places-r .x)))

(fn collect-places (x)
  (collect-places-r x)
  x)
