(fn list (&rest x) x)

(fn list-length (x)
  (let len 0
    (while (cons? x)
           len
      (= x .x)
      (++! len))))

(fn last (x)
  (& x
     (? .x
        (last .x)
        x)))

(fn copy-list (x)
  (? (atom x)
     x
     (. x. (copy-list .x))))

(functional nthcdr)

(fn nthcdr (idx x)
  (& x
     (? (zero? idx)
        x
        (nthcdr (-- idx) .x))))

(functional nth)

(fn nth (i x)
  (car (nthcdr i x)))

(fn filter (func lst)
  (let result (. nil nil)
    (@ (i lst .result)
      (rplaca result
              (cdr (rplacd (| result.
                              result)
                           (list (funcall func i))))))))

(fn mapcar (func &rest lists)
  (let-when args (%map-args lists)
    (. (apply func args)
       (apply #'mapcar func lists))))
