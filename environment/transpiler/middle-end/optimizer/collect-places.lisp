;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun collect-places-r (x)
  (?
    (named-lambda? x.) (with-lambda-funinfo x.
                         (!? (funinfo-lexical *funinfo*)
                             (= (funinfo-used-vars *funinfo*) (list !)))
                         (collect-places-r (lambda-body x.)))
    (%%go-cond? x.)    (& *funinfo*
                          (funinfo-add-used-var *funinfo* (%%go-value x.)))
    (%setq? x.)        (awhen *funinfo*
                          (funinfo-add-place ! (%setq-place x.))
                          (funinfo-add-used-var ! (%setq-place x.))
                          (? (atom (%setq-value x.))
                             (funinfo-add-used-var ! (%setq-value x.))
                             (dolist (i (%setq-value x.))
                               (funinfo-add-used-var ! i)))))
  (& x (collect-places-r .x)))

(defun collect-places (x)
  (collect-places-r x)
  x)
