(fn getf (k l)
  (? l
     (? (cons? l.)
        (cdr (assoc k l))
        (do ((l l .l))
            ((not l))
          (? (eql k l.)
             (return .l.))))))
