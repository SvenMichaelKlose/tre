(define-literal php-compiled-symbol compiled-symbols (x)
  :maker (make-symbol-identifier x)
  :initializer
      `(%native "new __symbol ("
                    (%string ,(symbol-name x)) ","
                    ,(? (keyword? x)
                        "$KEYWORDPACKAGE"
                        "NULL")
                ")"))
