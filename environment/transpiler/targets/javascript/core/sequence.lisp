(fn length (x)
  (? x
     (?
       (cons? x)            (list-length x)
       (defined? x.length)  x.length
       (object? x)          (list-length (property-names x))
       (error "LENGTH cannot handle %o." x))
     0))

(fn split (obj seq &key (test #'eql))
  (? (& (eq #'eql test)
        (string? seq))
     (array-list (seq.split (? (character? obj)
                               (char-string obj)
                               obj)))
     (generic-split obj seq)))
