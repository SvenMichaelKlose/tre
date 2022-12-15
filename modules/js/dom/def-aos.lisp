(defmacro def-aos-if (name args predicate)
  (with-gensym elm
    `(fn ,name (,elm ,@args)
       (ancestor-or-self-if ,elm ,predicate))))
