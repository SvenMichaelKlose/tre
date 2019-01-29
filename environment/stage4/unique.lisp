(fn unique (x &key (test #'eql))
  (when x
    (? (member x. .x :test test)
       (unique .x :test test)
       (. x. (unique .x :test test)))))
