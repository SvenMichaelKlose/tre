(fn c-expander-name (x)
  ($ x '_treexp))

(fn compile-argument-expansion-0 (fun-name adef p)
  (with ((argdefs key-args) (make-&key-alist adef)

         key
           #'(()
                (& key-args '((keywords))))

         static
           [`(,@(? (assert?)
                   `((| ,p
                        (error-argument-missing ',fun-name ,(symbol-name _.)))))
              (= ,_. (car ,p))
              (= ,p (cdr ,p))
              ,@(main ._))]

         optional
           [`(,@(key)
              (? ,p
                 (= ,(argdef-get-name _.) (car ,p)
                    ,p (cdr ,p))
                 ,@(& (cons? _.)
                      `((= ,(argdef-get-name _.) ,(argdef-get-default _.)))))
              ,@(& ._
                   (? (argument-keyword? ._.)
                      (main ._)
                      (optional ._))))]

         arest
           [(? (cons? _.)
               (error-&rest-has-value fun-name))
            `(,@(key)
              (= ,_. ,p)
              ,@(? (assert?)
                   `((= ,p nil))))]

         optional-rest
           [case _.
             '&rest     (arest ._)
             '&body     (arest ._)
             '&optional (optional ._)]

         sub
           [`(,@(key)
              (with-temporary ,p (car ,p)
                ,@(compile-argument-expansion-0 fun-name _. p))
                (= ,p (cdr ,p))
                ,@(main ._))]

         main
           [?
             (not _)                nil
             (argument-keyword? _.) (optional-rest _)
             (cons? _.)             (sub _)
             (static _)])
   (? key-args
      `((with (keywords
                  #'(()
                      (while (keyword? (car ,p))
                             nil
                          (?
                            ,@(mapcan [`((eq (car ,p) ,(make-keyword _))
                                         (= ,p (cdr ,p)
                                            ,_ (car ,p)
                                            ,p (cdr ,p)))]
                                      (carlist key-args))
                            (return nil)))))
          ,@(& argdefs
               (main argdefs))
          ,@(key)
          ,@(@ [`(& (eq ,_ ',_)
                    (= ,_ ,(cdr (assoc _ key-args))))]
               (carlist key-args))))
       (main argdefs))))

(fn compile-argument-expansion-function-body-0 (fun-name adef p names)
  `(,@(compile-argument-expansion-0 fun-name adef p)
    ,@(? (assert?)
         `((? ,p
              (error-too-many-arguments ,(symbol-name fun-name) ,(shared-defun-source adef) ,p))))
    ((%%native ,(compiled-function-name fun-name)) ,@names)))

(fn compile-argument-expansion-function-body (fun-name adef p)
  (body-with-noargs-tag
    (!? (argument-expand-names 'compile-argument-expansion adef)
        `((#'(,!
              ,@(compile-argument-expansion-function-body-0 fun-name adef p !))
            ,@(@ [`',_] !)))
        (compile-argument-expansion-function-body-0 fun-name adef p !))))

(fn compile-argument-expansion-function (this-name fun-name adef)
  (with-gensym p
    `(function ,this-name
               ((,p)
                  ,@(compile-argument-expansion-function-body fun-name adef p)))))

(fn compile-argument-expansion (this-name fun-name adef)
  (compile-argument-expansion-function this-name fun-name adef))
