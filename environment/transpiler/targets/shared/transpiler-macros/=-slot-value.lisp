(define-shared-transpiler-macro (bc c js php) =-slot-value (val obj slot)
  (?
    (quote? slot)  `(%= (%slot-value ,obj ,.slot.) ,val)
    (string? slot) `(%= (%slot-value ,obj ,slot) ,val)
    (atom slot)    `(%= (prop-value ,obj ,slot) ,val)
    (with-gensym g
      `(%%block
         (%var ,g)
         (%= ,g ,slot)
         (%= (prop-value ,obj ,g) ,val)
         ,val))))
