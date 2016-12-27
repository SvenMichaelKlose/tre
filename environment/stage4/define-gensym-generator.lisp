(defmacro define-gensym-generator (name prefix)
  (let counter ($ '* name '-counter*)
    `{(defvar ,counter 0)
      (defun ,name ()
        (alet ($ ',prefix (++! ,counter))
          (? (& (eq ! (symbol-value !))
                (not (symbol-function !)))
             !
             (,name))))}))
