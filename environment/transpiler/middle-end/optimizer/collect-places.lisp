(defun collect-places-r (x)
  (?
    (named-lambda? x.) (with-lambda-funinfo x.
                         (!? (funinfo-scope *funinfo*)
                             (= (funinfo-used-vars *funinfo*) (list !)))
                         (= (funinfo-places *funinfo*) nil)
                         (collect-places-r (lambda-body x.)))
    (%%go-cond? x.)    (funinfo-add-used-var *funinfo* (%%go-value x.))
    (%=? x.)           (let fi *funinfo*
                         (with-%= p v x.
                           (funinfo-add-place fi p)
                           (funinfo-add-used-var fi p)
                           (? (atom v)
                              (funinfo-add-used-var fi v)
                              (adolist v
                                (funinfo-add-used-var fi !))))))
  (& x (collect-places-r .x)))

(defun collect-places (x)
  (collect-places-r x)
  x)
