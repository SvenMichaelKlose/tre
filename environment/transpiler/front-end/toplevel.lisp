; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@hugbox.org>

(transpiler-end frontend
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
    fake-place-expand         [(place-expand _)
                               _]
    fake-expression-expand    #'fake-expression-expand)

(defun frontend-macroexpansions (x)
  (transpiler-macroexpand (compiler-macroexpand x)))
