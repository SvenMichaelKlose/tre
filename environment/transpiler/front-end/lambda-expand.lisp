;;;; INLINING

(fn lambda-expand-make-inline-body (stack-places values body)
  `(%block
     ,@(@ #'((stack-place init-value)
              `(%= ,stack-place ,init-value))
          stack-places
          values)
     ,@body))

(fn inline-binding-lambda (binding-lambda)
  (with-binding-lambda (args vals body binding-lambda)
    (with (l (argument-expand 'inline-binding-lambda args vals)
           a (carlist l)
           v (cdrlist l))
      (funinfo-add-var *funinfo* a)
      (lambda-expand (lambda-expand-make-inline-body a v body)))))


;;;; EXPORT

(def-gensym closure-name ~closure-)

(fn lambda-export (x)
  (with (name   (closure-name)
         args   (lambda-args x)
         body   (lambda-body x)
         new-fi (create-funinfo :name   name
                                :args   args
                                :parent *funinfo*))
    (funinfo-make-scope-arg new-fi)
    (transpiler-add-closure *transpiler* `((fn ,name ,args ,@body)))
    `(%closure ,name)))


;;;; PASSTHROUGH

(fn lambda-expand-lambda (x)
  "Ensure that function expression X has a FUNINFO."
  "Creates name for anonymous function."
  (!? (lambda-funinfo x)
      (with-temporary *funinfo* !
        (copy-lambda x :body (lambda-expand (lambda-body x))))
      (with (name   (| (lambda-name x)
                       (funinfo-sym))
             args   (lambda-args x)
             new-fi (create-funinfo :name   name
                                    :args   args
                                    :parent *funinfo*))
        (funinfo-add-var *funinfo* name)
        (with-temporary *funinfo* new-fi
          (copy-lambda x :name name
                         :args args
                         :body (lambda-expand (lambda-body x)))))))


;;;; TOPLEVEL

(fn lambda-expand-collection (x)
  `(%collection ,.x.
     ,@(@ [. '%inhibit-macro-expansion (. ._. (lambda-expand-expr .._))] ..x)))

(fn lambda-expand-expr (x)
  (pcase x
    atom            x
    binding-lambda? (inline-binding-lambda x)
    unnamed-lambda? (? (lambda-export?)
                       (lambda-export x)
                       (lambda-expand-lambda x))
    named-lambda?   (lambda-expand-lambda x)
    %collection?    (lambda-expand-collection x)
    (lambda-expand x)))

(define-filter lambda-expand #'lambda-expand-expr)
