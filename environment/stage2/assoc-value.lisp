(functional assoc-value)

(fn assoc-value (key lst &key (test #'eql))
  (cdr (assoc key lst :test test)))

(fn (= assoc-value) (val key lst &key (test #'eql))
  (!? (assoc key lst :test test)
      (= .! val)
      (acons! key val lst)))
