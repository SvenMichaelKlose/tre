(defmacro def-aos-if (name args predicate)
  (with-gensym elm
    `(defun ,name (,elm ,@args)
       (ancestor-or-self-if ,elm ,predicate))))
