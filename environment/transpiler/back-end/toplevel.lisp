(define-transpiler-end :backend
    :backend-input             #'identity
    :make-framed-functions     #'make-framed-functions
    :place-expand              #'place-expand
    :place-assign              #'place-assign
    :warn-unused               #'warn-unused
    :collect-used-functions    [(collect-used-functions _) _]
    :translate-function-names  #'translate-function-names
    :encapsulate-strings       #'encapsulate-strings
    :wrap-tags                 #'wrap-tags
    :count-tags                #'count-tags
    :codegen-expand            #'codegen-expand
    :convert-identifiers       #'convert-identifiers
    :output-filter             #'flatten)
