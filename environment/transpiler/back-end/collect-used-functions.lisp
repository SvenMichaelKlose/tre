(define-filter collect-used-functions (x)
  (?
    (%=-funcall? x)
      (@ [& (defined-function x)
            (not (funinfo-find *funinfo* x))
            (add-used-function x)]
         ..x.)
    (named-lambda? x)
      (with-lambda-funinfo x
        (collect-used-functions (lambda-body x)))))
