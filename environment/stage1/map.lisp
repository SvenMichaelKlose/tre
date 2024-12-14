(fn %map-args (lists)
  (block nil
    (let* ((i  lists)
           (nl (make-queue)))
      (tagbody
        start
        (? (not i)
           (return (queue-list nl)))
        (? (not (car i))
           (return nil))
        (enqueue nl (car (car i)))
        (rplaca i (cdr (car i)))
        (setq i (cdr i))
        (go start)))))

(fn mapcar (func &rest lists)
  (let-if args (%map-args lists)
    (. (*> func args)
       (*> #'mapcar func lists))))

(fn mapcan (func &rest lists)
  (*> #'append (*> #'mapcar func lists)))
