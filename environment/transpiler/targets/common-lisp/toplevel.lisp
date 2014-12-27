; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(defun tre-expansions (x)
  (backquote-expand (quasiquote-expand (macroexpand (dot-expand x)))))
(defun expr2cl (x)                 (make-lambdas (tre-expansions x)))
(defun file2cl (pathname)          (expr2cl (read-file pathname)))
(defun files2cl (&rest pathnames)  (. 'progn (mapcan #'file2cl pathnames)))

(defun cl-expex-initializer (ex)
  (= (expex-argument-filter ex) #'identity
     (expex-setter-filter ex)   #'identity))

(defun cl-frontend (x)
  (alet (transpiler-macroexpand (quasiquote-expand (dot-expand x)))
    (fake-expression-expand (fake-place-expand (lambda-expand (rename-arguments (backquote-expand (compiler-macroexpand !))))))
    (make-lambdas !)))

(defun cl-sections-before-deps ()
  (unless (exclude-base?)
    (list (. 'cl-base *cl-base*))))

(defun make-cl-transpiler ()
  (create-transpiler
      :name                  :common-lisp
      :frontend-only?        t
      :import-variables?     t
      :lambda-export?        nil
      :stack-locals?         nil
      :sections-before-deps  #'cl-sections-before-deps
      :frontend-init         #'(() (= *cl-builtins* nil))
      :own-frontend          #'cl-frontend
      :expex-initializer     #'cl-expex-initializer))

(defvar *cl-transpiler* (copy-transpiler (make-cl-transpiler)))
