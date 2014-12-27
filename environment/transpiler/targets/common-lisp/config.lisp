; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun cl-expex-initializer (ex)
  (= (expex-argument-filter ex) #'identity
     (expex-setter-filter ex)   #'identity))

(defun cl-frontend (x)
  (aprog1 (transpiler-macroexpand (quasiquote-expand (dot-expand x)))
    (fake-expression-expand (fake-place-expand (lambda-expand (rename-arguments (backquote-expand (compiler-macroexpand !))))))))

(defun make-cl-transpiler ()
  (create-transpiler
      :name               :common-lisp
      :frontend-only?     t
      :import-variables?  t
      :lambda-export?     nil
      :stack-locals?      nil
      :frontend-init      #'(() (= *cl-builtins* nil))
      :own-frontend       #'cl-frontend
      :expex-initializer  #'cl-expex-initializer
      :postprocessor      #'make-lambdas))

(defvar *cl-transpiler* (copy-transpiler (make-cl-transpiler)))
