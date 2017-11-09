(define-shared-std-macro (bc c js php) =-slot-value (val obj slot)
  (?
    (quote? slot)  `(%= (%slot-value ,obj ,.slot.) ,val)
    (atom slot)    `(%= (%property-value ,obj ,slot) ,val)
    (with-gensym g
      `(%%block
         (%var ,g)
         (%= ,g ,slot)
         (!= (%property-value ,obj ,g) ,val)
         ,val))))
