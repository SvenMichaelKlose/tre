(functional queue-list queue-front)

(fn make-queue ()
  (. nil nil))

(fn enqueue (x &rest vals)
  (rplaca x (cdr (rplacd (| x. x) vals)))
  vals)

(fn enqueue-list (x vals)
  (rplacd x (nconc .x vals))
  (rplaca x (last vals)))

(fn queue-pop (x)
  (prog1 .x.
    (? (not ..x)
       (rplaca x nil))
    (? .x
       (rplacd x ..x))))

(fn queue-list (x) .x)
(fn queue-front (x) .x.)
