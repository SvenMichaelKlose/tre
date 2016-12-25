(defmacro define-codegen-macro-definer (name tr-ref)
  `(defmacro ,name (&rest x)
     (print-definition `(,name ,,x.))
     `{(define-codegen-macro ,tr-ref ,,@x)}))
