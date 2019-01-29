(fn length (x)
  (? x
     (? (cons? x)
        (list-length x)
        x.length)
     0))

(fn split (obj seq &key (test #'eql))
  (? (& (eq #'eql test)
        (string? seq))
     (array-list (seq.split (? (character? obj)
                               (char-string obj)
                               obj)))
     (generic-split obj seq)))
