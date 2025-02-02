(fn nested-fn-smoke-test (x)
  (fn r (x) x)
  (r x))

(| (eq 'done (nested-fn-smoke-test 'done))
   (error "Not done"))

(quit)
