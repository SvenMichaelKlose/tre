; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(transpiler-pass frontend-2 ()
    thisify                   [thisify (thisify-classes) _]
    rename-arguments          #'rename-arguments
    lambda-expand             #'lambda-expand
    fake-place-expand         #'fake-place-expand
    fake-expression-expand    [(with-temporary *expex-import?* t
                                 (expression-expand (make-packages _)))
                               _])

(transpiler-pass frontend-1 ()
    file-input                #'identity
    dot-expand                [? (dot-expand?)
                                 (dot-expand _)
                                 _]
    quasiquote-expand         #'quasiquote-expand
    transpiler-macroexpand    #'transpiler-macroexpand
    compiler-macroexpand      #'compiler-macroexpand
    backquote-expand          #'backquote-expand
    literal-conversion        [funcall (literal-converter) _])

(defun frontend-0 (x)
  (frontend-2 (frontend-1 x)))

(defun frontend (x)
  (remove-if #'not (mapcan [(= *default-listprop* nil)
                            (frontend-0 (list _))]
                           x)))

(defun frontend-macroexpansions (x)
  (transpiler-macroexpand (compiler-macroexpand x)))
