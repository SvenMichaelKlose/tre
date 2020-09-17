(defmacro def-gensym (name prefix)
  (let counter ($ '* name '-counter*)
    `(progn
       (var ,counter 0)
       (fn ,name ()
         (!= ($ ',prefix (++! ,counter))
           (? (& (eq ! (symbol-value !))
                 (not (symbol-function !)))
              !
              (,name)))))))
