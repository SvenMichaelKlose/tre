(define-transpiler-end :middleend
    :middleend-input          #'identity
    :remove-empty-statements  [remove-if #'not _]
    :call-expand              #'call-expand
    :expression-expand        #'expression-expand
    :validate-metacode        #'validate-metacode
    :unassign-named-functions #'unassign-named-functions
    :accumulate-toplevel      #'accumulate-toplevel-expressions
    :collect-keywords         #'collect-keywords
    :optimize                 #'optimize
    :opt-tailcall             #'opt-tailcall
    :delay-statements         #'delay-statements
    :validate-metacode        #'validate-metacode)
