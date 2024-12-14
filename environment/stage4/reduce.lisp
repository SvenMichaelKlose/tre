(fn reduce (f l &optional initial-value)
  "Reduce list L using function F, optionally starting with INITIAL-VALUE."
  (? l
     (with (result (? initial-value
                      (funcall f initial-value l.)
                      l.))
      (@ (i .l result)
        (= result (funcall f result i))))
     initial-value))
