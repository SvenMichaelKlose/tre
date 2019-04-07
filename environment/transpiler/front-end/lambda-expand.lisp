;;;; INLINING

(fn lambda-expand-make-inline-body (stack-places values body)
  `(%%block
     ,@(@ #'((stack-place init-value)
              `(%= ,stack-place ,init-value))
          stack-places
          values)
     ,@body))

(fn lambda-call-embed (lambda-call)
  (with-lambda-call (args vals body lambda-call)
    (with (l  (argument-expand 'dummy-in-lambda-call-embed args vals)
           a  (carlist l)
           v  (cdrlist l))
      (@ [funinfo-var-add *funinfo* _] a)
      (lambda-expand-r (lambda-expand-make-inline-body a v body)))))


;;;; EXPORT

(define-gensym-generator closure-name ~closure-)

(fn lambda-export (x)
  (with (name    (closure-name)
         args    (lambda-args x)
         body    (lambda-body x)
         new-fi  (create-funinfo :name    name
                                 :args    args
                                 :parent  *funinfo*))
    (funinfo-make-scope-arg new-fi)
    (transpiler-add-closure *transpiler* `((fn ,name ,args ,@body)))
    `(%closure ,name)))


;;;; PASSTHROUGH

(fn lambda-expand-r-unexported-lambda (x)
  (!? (get-lambda-funinfo x)
      (with-temporary *funinfo* !
        (copy-lambda x :body (lambda-expand-r (lambda-body x))))
      (with (name    (| (lambda-name x)
                        (funinfo-sym))
             args    (lambda-args x)
             new-fi  (create-funinfo :name    name
                                     :args    args
                                     :parent  *funinfo*))
        (funinfo-var-add *funinfo* name)
        (with-temporary *funinfo* new-fi
          (copy-lambda x :name  name
                         :args  args
                         :body  (lambda-expand-r (lambda-body x)))))))


;;;; TOPLEVEL

(fn lambda-expand-expr (x)
  (pcase x
    lambda-call?   (lambda-call-embed x)
    lambda?        (? (lambda-export?)
                      (lambda-export x)
                      (lambda-expand-r-unexported-lambda x))
    named-lambda?  (lambda-expand-r-unexported-lambda x)
    (lambda-expand-r x)))

(fn lambda-expand-r (x)
  (?
    (atom x)   x
    (atom x.)  (. x. (lambda-expand-r .x))
    (. (lambda-expand-expr x.)
       (lambda-expand-r .x))))

(fn lambda-expand (x)
  (with-global-funinfo
    (lambda-expand-r x)))
