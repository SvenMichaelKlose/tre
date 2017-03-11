(fn length (x)
  (?
    (not x) 0
    (cons? x) (list-length x)
    (string? x) (strlen x)
    (is_a x "__array") (x.length)
    (is_array x) (sizeof x)))

(fn split (obj seq &key (test #'eql))
  (? (& (eq #'eql test) (string? seq))
     (array-list (explode (? (character? obj)
                             (char-string obj)
                             obj)
                          seq))
     (generic-split obj seq)))
