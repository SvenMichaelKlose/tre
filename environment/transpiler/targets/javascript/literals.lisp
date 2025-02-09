(define-literal js-compiled-symbol compiled-symbols (x)
  :maker (make-symbol-identifier x)
  :initializer
    (!= (compiled-function-name-string 'symbol)
        `(%native ,! " (\"" ,(symbol-name x) "\", "
                        ,@(? (keyword? x)
                             '("KEYWORDPACKAGE")
                             `(,! "(\""
                                   ,(symbol-name :tre) ;(symbol-package x))
                                  "\")"))
                     ")")))
