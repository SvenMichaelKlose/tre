;;;;; tré – Copyright (c) 2009–2014 Sven Michael Klose <pixel@copei.de>

(defun collect-places-r (x)
  (?
    (named-lambda? x.) (with-lambda-funinfo x.
                         (!? (funinfo-scope *funinfo*)
                             (= (funinfo-used-vars *funinfo*) (list !)))
                         (collect-places-r (lambda-body x.)))
    (%%go-cond? x.)    (funinfo-add-used-var *funinfo* (%%go-value x.))
    (%=? x.)           (awhen *funinfo*
                         (funinfo-add-place ! (%=-place x.))
                         (funinfo-add-used-var ! (%=-place x.))
                         (? (atom (%=-value x.))
                            (funinfo-add-used-var ! (%=-value x.))
                            (dolist (i (%=-value x.))
                              (funinfo-add-used-var ! i)))))
  (& x (collect-places-r .x)))

(defun collect-places (x)
  (collect-places-r x)
  x)
