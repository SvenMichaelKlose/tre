(fn %map-args (lists)
  (block nil
    (let* ((i lists)            ; List iterator.
           (nl (make-queue)))   ; Argument list.
      (tagbody
        start
        (? (not i)
           (return (queue-list nl)))
        (? (not (car i))        ; Break if any list has no more elements.
           (return nil))
        (enqueue nl (caar i))   ; Add head of list to list of arguments
        (rplaca i (cdar i))     ; Move pointer to next element in list.
        (setq i (cdr i))        ; Go for next list.
        (go start)))))

(fn map (func &rest lists)
  (let args (%map-args lists)
    (when args
      (apply func args)
      (apply #'map func lists)))
  nil)

(fn mapcan (func &rest lists)
  (apply #'nconc (apply #'mapcar func lists)))
