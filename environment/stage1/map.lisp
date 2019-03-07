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

(fn dynamic-map (func &rest lists)
  (?
    (string? lists.)  (list-string (apply #'mapcar func (mapcar #'string-list lists)))
    (array? lists.)   (list-array (apply #'mapcar func (mapcar #'array-list lists)))
    (apply #'mapcar func lists)))

(fn mapcan (func &rest lists)
  (apply #'nconc (apply #'mapcar func lists)))
