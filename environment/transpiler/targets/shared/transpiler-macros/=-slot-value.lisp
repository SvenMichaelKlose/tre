(def-shared-transpiler-macro (bc c js php) =-slot-value (val obj slot)
  (?
    (quote? slot)  `(%= (%slot-value ,obj ,.slot.) ,val)
    (string? slot) `(%= (%slot-value ,obj ,slot) ,val)
    (atom slot)    `(%= (%aref ,obj ,slot) ,val)
    (with-gensym g
      `(%%block
         (%var ,g)
         (%= ,g ,slot)
         (%= (%aref ,obj ,g) ,val)
         ,val))))
