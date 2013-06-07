;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(transpiler-pass transpiler-frontend-2 (tr)
    thisify                   [thisify (transpiler-thisify-classes tr) _]
    cpr                       [cpr-count _ "thisify"]
    opt-inline                [? *opt-inline?*
                                 (opt-inline tr _)
	                             _]
    cpr                       [cpr-count _ "opt-inline"]
    rename-function-arguments #'rename-function-arguments
    cpr                       [cpr-count _ "rename args"]
    lambda-expand             [transpiler-lambda-expand tr _]
    cpr                       [cpr-count _ "lambda expand"]
    fake-expression-expand    [(validate-metacode (transpiler-expression-expand tr (make-packages _)))
                               _])

(transpiler-pass transpiler-frontend-1 (tr)
    file-input                #'identity
    cpr                       [cpr-count _ "file input"]
    dot-expand                [? (transpiler-dot-expand? tr)
                                 (dot-expand _)
                                 _]
    cpr                       [cpr-count _ "dot expand"]
    transpiler-macroexpand-1  [? (transpiler-dot-expand? tr)
                                 (transpiler-macroexpand tr _)
                                 _]
    cpr                       [cpr-count _ "macroexpand"]
    quasiquote-expand         #'quasiquote-expand
    cpr                       [cpr-count _ "quasiquote-expand"]
    transpiler-macroexpand-2  [transpiler-macroexpand tr _]
    cpr                       [cpr-count _ "macroexpand"]
    compiler-macroexpand      #'compiler-macroexpand
    cpr                       [cpr-count _ "compiler-macroexpand"]
    backquote-expand          #'backquote-expand
    cpr                       [cpr-count _ "backquote-macroexpand"]
    literal-conversion        [funcall (transpiler-literal-conversion tr) _]
    cpr                       [cpr-count _ "literal conversion"])

(defun transpiler-frontend-0 (tr x)
  (transpiler-frontend-2 tr (transpiler-frontend-1 tr x)))

(defun transpiler-frontend (tr x)
  (remove-if #'not (mapcan [transpiler-frontend-0 tr (list _)] x)))

(defun transpiler-frontend-file (tr file)
  (format t "(LOAD \"~A\")~%" file)
  (force-output)
  (transpiler-frontend tr (read-file-all file)))
