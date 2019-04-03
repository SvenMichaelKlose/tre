(define-transpiler-end :frontend
    frontend-input            #'identity
    dot-expand                #'dot-expand
    quasiquote-expand         #'quasiquote-expand
    transpiler-macroexpand    #'transpiler-macroexpand
    compiler-macroexpand      #'compiler-macroexpand
    quote-expand              #'quote-expand
    literal-conversion        [funcall (literal-converter) _]
    thisify                   #'thisify
    rename-arguments          #'rename-arguments
    lambda-expand             #'lambda-expand
    initialize-funinfos       [(place-expand _)
                               _]
    expression-expand         #'expression-expand
    unassign-lambdas          #'unassign-lambdas
    gather-imports            #'gather-imports)
