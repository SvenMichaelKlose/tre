(define-transpiler-end :frontend
    :frontend-input             #'identity
    :dot-expand                 #'dot-expand
    :quasiquote-expand          #'quasiquote-expand
    :transpiler-macroexpand     #'transpiler-macroexpand
    :gather-imports             #'gather-imports
    :compiler-macroexpand       #'compiler-macroexpand
    :quote-expand               #'quote-expand
    :expand-literal-characters  #'expand-literal-characters
    :thisification              #'thisify
    :rename-arguments           #'rename-arguments
    :lambda-expand              #'lambda-expand
    :call-expand                #'call-expand
    :expression-expand          #'expression-expand)
