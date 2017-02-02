(fn intersect (a b &key (test #'eql))
  (& a b
     (? (member a. b :test test)
        (. a. (intersect .a b))
        (intersect .a b))))
