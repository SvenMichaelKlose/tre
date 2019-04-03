(defmacro def-codegen-macro (name tr-ref)
  `(defmacro ,name (&rest x)
     (print-definition `(,name ,,x.))
     `{(define-codegen-macro ,tr-ref ,,@x)}))
