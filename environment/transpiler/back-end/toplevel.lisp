(define-transpiler-end :backend-generate-code
    :backend-input             #'identity
    :collect-used-functions    [(collect-used-functions _) _]
    :translate-function-names  #'translate-function-names
    :encapsulate-strings       #'encapsulate-strings
    :wrap-tags                 #'wrap-tags
    :count-tags                #'count-tags
    :codegen-expand            #'codegen-expand
    :convert-identifiers       #'convert-identifiers
    :output-filter             #'flatten)

(define-transpiler-end :backend-make-places
    :place-expand  #'place-expand
    :place-assign  #'place-assign
    :warn-unused   #'warn-unused)

(fn backend-prepare (x)
  (!= (make-framed-functions x)
    (? (lambda-export?)
       (backend-make-places !)
       !)))

(fn backend (x)
  (? (enabled-end? :backend)
     (@ [backend-generate-code (backend-prepare (list _))] x)
     x))
