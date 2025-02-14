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

(def-gensym closure-name ~closure-)

(fn lambda-export (x)
  (with (name   (closure-name)
         args   (lambda-args x))
    (funinfo-make-scope-arg
        (create-funinfo :name   name
                        :args   args
                        :parent *funinfo*))
    (transpiler-add-closure *transpiler*
        `((fn ,name ,args
            ,@(lambda-body x))))
    `(%closure ,name)))

(fn lambda-expand-lambda (x)
  "Ensure that function expression X has a FUNINFO."
  "Creates name for anonymous function."
  (with (name (| (lambda-name x)
                 (funinfo-sym)))
    (funinfo-add-var *funinfo* name)
    (create-funinfo :name   name
                    :args   (lambda-args x)
                    :parent *funinfo*)
    (do-lambda x :name name
       :body (lambda-expand (lambda-body x)))))

(fn lambda-expand-collection (x)
  `(%collection ,.x.
     ,@(@ [. '%inhibit-macro-expansion
             (. ._. (lambda-expand-expr .._))]
          ..x)))

(fn lambda-expand-expr (x)
  (pcase x
    atom x
    binding-lambda?
      (inline-binding-lambda x)
    unnamed-lambda?
      (? (lambda-export?)
         (lambda-export x)
         (lambda-expand-lambda x))
    named-lambda?
      (do-lambda x
        :body (lambda-expand (lambda-body x)))
    %collection?
      (lambda-expand-collection x)
    (lambda-expand x)))

(define-filter lambda-expand #'lambda-expand-expr)
