(define-compiled-literal js-compiled-symbol (x symbol)
  :maker       (make-compiled-symbol-identifier x)
  :init-maker  (let s (compiled-function-name-string 'symbol)
                 `(%%native ,s " (\"" ,(symbol-name x) "\", "
                               ,@(? (keyword? x)
                                    '("KEYWORDPACKAGE")
                                    `(,s "(\"" ,(symbol-name (symbol-package x)) "\")"))
                               ")")))
