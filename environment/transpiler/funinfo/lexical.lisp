(fn funinfo-scope-arg? (fi x)
  (eq x (funinfo-scope-arg fi)))

(fn funinfo-make-scope (fi)
  (unless (funinfo-scope fi)
    (with-gensym scope
      (= (funinfo-scope fi) scope)
      (funinfo-add-var fi scope))))

(fn funinfo-make-scope-arg (fi)
  (unless (funinfo-scope-arg fi)
    (with-gensym scope-arg
      (= (funinfo-scope-arg fi) scope-arg)
      (push scope-arg (funinfo-argdef fi))
      (push scope-arg (funinfo-args fi)))))

(fn funinfo-setup-scope (fi x)
  (!= (funinfo-parent fi)
    (| ! (error "Couldn't find ~A in environment"
                (funinfo-name fi)))
    (when (lambda-export?)
      (funinfo-make-scope !)
      (funinfo-make-scope-arg fi))
    (? (funinfo-arg-or-var? ! x)
       (funinfo-add-scoped-var ! x)
       (funinfo-setup-scope ! x))))
