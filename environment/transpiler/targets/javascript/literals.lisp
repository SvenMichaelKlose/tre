(define-compiled-literal js-compiled-symbol (x symbol)
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
