(define-transpiler-end :middleend
    middleend-input          #'identity
    expression-expand        #'expression-expand
    unassign-lambdas         #'unassign-lambdas
    accumulate-toplevel      #'accumulate-toplevel-expressions
    quote-keywords           #'quote-keywords
    validate-metacode        #'validate-metacode
    optimize                 #'optimize
    opt-tailcall             #'pass-opt-tailcall)
