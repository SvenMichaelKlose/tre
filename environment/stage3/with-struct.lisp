(defmacro with-struct (typ strct &body body)
  (!= (assoc-value typ *struct-defs*)
    (with-gensym g
      `(let ,g ,strct
         (#'((,typ ,@(@ #'%struct-field-name !))
             ,@(@ [%struct-field-name _] !)
             ,@body)
          ,g ,@(@ [`(,(%struct-accessor-name typ (%struct-field-name _)) ,g)] !))))))
