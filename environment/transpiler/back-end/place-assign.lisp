(fn unassigned-%stackarg? (x)
  (& (%stackarg? x) ..x))

(fn unassigned-%stack? (x)
  (& (%stack? x) ..x))

(fn unassigned-%vec? (x)
  (& (%vec? x) ...x))

(fn unassigned-%set-vec? (x)
  (& (%set-vec? x) ....x))

(fn place-assign-error (x v)
  (funinfo-error "Can't assign place because the index in scoped vars for ~A is missing in ~A." v x))

(fn place-assign-stackarg (x)
  (let fi (get-funinfo .x.)
    (? (arguments-on-stack?)
       (integer (+ (length (funinfo-vars fi)) (- (length (funinfo-args fi)) (funinfo-arg-pos fi ..x.) 1)))
       (funinfo-error "Cannot assign stack argument ~A." ..x.))))

(define-tree-filter place-assign (x)
  (| (quote? x)
     (%%native? x))          x
  (unassigned-%stackarg? x)  `(%stack ,(place-assign-stackarg x))
  (unassigned-%stack? x)     `(%stack ,(| (funinfoname-var-pos .x. ..x.)
                                          (place-assign-stackarg x)))
  (unassigned-%vec? x)       `(%vec ,(place-assign .x.)
                                    ,(| (funinfoname-scoped-var-index ..x. ...x.)
                                          (place-assign-error x ...x.)))
  (unassigned-%set-vec? x)   `(%set-vec ,(place-assign .x.)
                                        ,(| (funinfoname-scoped-var-index ..x. ...x.)
                                            (place-assign-error x ...x.))
                                        ,(place-assign ....x.))
  (named-lambda? x)          (copy-lambda x :body (place-assign (lambda-body x)))
  (%slot-value? x)           `(%slot-value ,(place-assign .x.) ,..x.))
