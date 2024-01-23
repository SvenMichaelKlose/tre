(fn ref (o &rest indexes)
  (@ (i indexes o)
    (= o (?
           (cons? o)        (assoc-value i o)
           (array? o)       (aref o i)
           (hash-table? o)  (href o i)
           (object? o)      (oref o i)))))

(fn (= ref) (v o &rest indexes)
  (= o (apply #'ref o (butlast indexes)))
  (!= (car (last indexes))
    (?
      (cons? o)        (= (assoc-value o !) v)
      (array? o)       (= (aref o !) v)
      (hash-table? o)  (= (href o !) v)
      (object? o)      (=-oref v o !))))

(fn ^ (o &rest indexes)
  (apply #'ref o indexes))

(fn =-^ (v o &rest indexes)
  (apply #'=-ref v o indexes))
