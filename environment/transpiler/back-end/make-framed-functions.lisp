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

(metacode-walker make-framed-functions (x)
  :if-named-function
      (let name (lambda-name x.)
        `(,@(& (needs-var-declarations?)
               (funinfo-var-declarations *funinfo*))
          ,@(& (function-frames?)
               `((%function-prologue ,name)))
          ,@(& (lambda-export?)
               (funinfo-copiers-to-scoped-vars *funinfo*))
          ,@(make-framed-functions (lambda-body x.))
          ,@(& (function-frames?)
               `((%function-epilogue ,name))))))
