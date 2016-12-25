(functional queue-list queue-front)

(defun make-queue ()
  (. nil nil))

(defun enqueue (x &rest vals)
  (rplaca x (cdr (rplacd (| x. x) vals)))
  vals)

(defun enqueue-list (x vals)
  (rplacd x (nconc .x vals))
  (rplaca x (last vals)))

(defun queue-pop (x)
  (prog1 .x.
    (? (not ..x)
       (rplaca x nil))
    (? .x
       (rplacd x ..x))))

(defun queue-list (x) .x)
(defun queue-front (x) .x.)

(define-test "ENQUEUE and QUEUE-LIST work"
  ((let q (make-queue)
     (enqueue q 'a)
     (enqueue q 'b)
     (queue-list q)))
  '(a b))
