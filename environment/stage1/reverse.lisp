(functional reverse)

(fn reverse (lst)
  (!= nil
    (@ (i lst !)
      (push i !))))
