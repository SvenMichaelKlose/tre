(functional make-queue queue-list queue-front)

(fn make-queue ()
  (. () ()))

(fn enqueue (x &rest vals)
  (rplaca x (cdr (rplacd (| x. x) vals)))
  vals)

(fn enqueue-list (x vals)
  (rplacd x (nconc .x vals))
  (rplaca x (last vals)))

(fn queue-pop (x)
  (prog1 .x.
    (| (rplacd x ..x)
       (rplaca x nil))))

(fn queue-list (x) .x)
(fn queue-front (x) .x.)
