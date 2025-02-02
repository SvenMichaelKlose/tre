(define-literal php-compiled-symbol (x symbol)
  :maker (make-symbol-identifier x)
  :initializer
      `(%native "new __symbol ("
                    (%string ,(symbol-name x)) ","
                    ,(? (keyword? x)
                        "$KEYWORDPACKAGE"
                        "NULL")
                ")"))
