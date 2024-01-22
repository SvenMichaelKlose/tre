(fn collect-used-functions (x)
  (with (r [@ [?
                (& (%=? _)
                   (cons? .._.))
                  (@ [& (defined-function _)
                        (not (funinfo-find *funinfo* _))
                        (add-used-function _)]
                     .._.)
                (named-lambda? _)
                  (with-lambda-funinfo _
                    (r (lambda-body _)))]
              _])
    (with-global-funinfo
      (r x)))
  x)
