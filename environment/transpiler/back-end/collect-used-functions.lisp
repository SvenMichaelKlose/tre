(fn collect-used-functions (x)
  (with (r #'((x)
               (when x
                 (?
                   (& (%=? x.)
                      (cons? (caddr x.)))
                     (mapcar [& (defined-function _)
                                (not (funinfo-find *funinfo* _))
                                (add-used-function _)]
                             (caddr x.))
                   (named-lambda? x.)
                     (with-lambda-funinfo x.
                       (r (lambda-body x.))))
                 (r .x))))
    (with-global-funinfo
      (r x)))
  x)
