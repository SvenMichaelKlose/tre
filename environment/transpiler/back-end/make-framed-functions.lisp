(fn funinfo-var-declarations (fi)
  (unless (stack-locals?)
    (!? (funinfo-vars fi)
        `((%var ,@(remove-if [funinfo-arg? fi _] !))))))

(fn funinfo-copiers-to-scoped-vars (fi)
  (let-when scoped-vars (funinfo-scoped-vars fi)
    (let scope (funinfo-scope fi)
      `((%= ,scope (%make-scope ,(length scoped-vars)))
        ,@(!? (funinfo-scoped-var? fi scope)
              `((%set-vec ,scope ,! ,scope)))
        ,@(@ [`(%= ,_ ,(? (arguments-on-stack?)
                          `(%stackarg ,(funinfo-name fi) ,_)
                          `(%native ,_)))]
              (remove-if-not [funinfo-scoped-var? fi _]
                             (funinfo-args fi)))))))

(fn make-framed-function (x)
  (with (fi   (lambda-funinfo x)
         name (funinfo-name fi))
    (copy-lambda x
        :body `(,@(& (needs-var-declarations?)
                     (funinfo-var-declarations fi))
                ,@(& (function-frames?)
                     `((%function-prologue ,name)))
                ,@(& (lambda-export?)
                     (funinfo-copiers-to-scoped-vars fi))
                ,@(make-framed-functions (lambda-body x))
                ,@(& (function-frames?)
                     `((%function-epilogue ,name)))))))

(define-tree-filter make-framed-functions (x)
  (named-lambda? x)
    (make-framed-function x))
