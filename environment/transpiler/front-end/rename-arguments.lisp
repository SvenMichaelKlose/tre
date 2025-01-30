(def-gensym argument-sym a)

(fn rename-arguments (x &optional (replacements nil))
  (with (f #'((lambda-form replacements)
               (? (lambda-funinfo lambda-form)
                  lambda-form
                  (!= (+ (@ [. _ (argument-sym)]
                            (argument-expand-names (lambda-name lambda-form)
                                                   (lambda-args lambda-form)))
                         replacements)
                    (copy-lambda lambda-form
                                 :args (r (lambda-args lambda-form) !)
                                 :body (r (lambda-body lambda-form) !)))))
         r #'((x replacements)
               (?
                 (atom x)
                   (? (macro? x)
                      (error "Cannot use macro name ~A as an argument name." x)
                      (| (assoc-value x replacements :test #'eq)
                         x))
                 (quote? x)
                   x
                 (lambda? x)
                   (f x replacements)
                 (%slot-value? x)
                   `(%slot-value ,(r .x. replacements) ,..x.)
                 (. (r x. replacements)
                    (r .x replacements)))))
    (= *argument-sym-counter* 0)
    (r x replacements)))
