(define-compiled-literal php-compiled-symbol (x symbol)
  :maker
      ($ 'symbol_ (? (keyword? x) '_ "") x)
  :init-maker
      `(%%native "new __symbol ("
                     (%%string ,(symbol-name x))
                     ","
                     ,(? (keyword? x)
                         "$KEYWORDPACKAGE"
                         "NULL")
                 ")"))
