(fn c-expander-name (x)
  ($ x '_treexp))

(fn make-argument-expander-0 (fname adef p)
  (with ((argdefs key-args) (make-&key-alist adef)

         key
           #'(()
                (& key-args '((keywords))))

         static
           [`(,@(? (assert?)
                   `((| ,p
                        (error-argument-missing ',fname ,(symbol-name _.)))))
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
               (error-&rest-has-value fname))
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
                ,@(make-argument-expander-0 fname _. p))
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
                            ,@(+@ [`((eq (car ,p) ,(make-keyword _))
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

(fn make-argument-expander-function-body-0 (fname adef p names)
  `(,@(make-argument-expander-0 fname adef p)
    ,@(? (assert?)
         `((? ,p
              (error-too-many-arguments ,(symbol-name fname) ,(shared-defun-source adef) ,p))))
    ((%fname ,fname) ,@names)))

(fn make-argument-expander-function-body (fname adef p)
  (. 'has-argexp!
     (!? (argument-expand-names 'make-argument-expander adef)
         `((#'(,!
               ,@(make-argument-expander-function-body-0 fname adef p !))
             ,@(@ [`',_] !)))
         (make-argument-expander-function-body-0 fname adef p !))))

(fn make-argument-expander-function (this-name fname adef)
  (with-gensym p
    `(function ,this-name
               ((,p)
                  ,@(make-argument-expander-function-body fname adef p)))))

(fn make-argument-expander (this-name fname adef)
  (make-argument-expander-function this-name fname adef))
