(defmacro define-gensym-generator (name prefix)
  (let counter ($ '* name '-counter*)
    `{(var ,counter 0)
      (fn ,name ()
        (alet ($ ',prefix (++! ,counter))
          (? (& (eq ! (symbol-value !))
                (not (symbol-function !)))
             !
             (,name))))}))
