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
        (enqueue nl (car (car i)))   ; Add head of list to list of arguments
        (rplaca i (cdr (car i)))     ; Move pointer to next element in list.
        (setq i (cdr i))        ; Go for next list.
        (go start)))))

(fn mapcar (func &rest lists)
  (let-if args (%map-args lists)
    (. (*> func args)
       (*> #'mapcar func lists))))
