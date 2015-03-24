; tré – Copyright (c) 2005–2015 Sven Michael Klose <pixel@hugbox.org>

(defun cl-postprocessor (&rest x)
  (make-lambdas (apply #'+ x)))

(defun cl-frontend (x)
  (? (dump-passes?)
     (format t "; #### CL-FRONTED ####"))
  (aprog1 (transpiler-macroexpand (quasiquote-expand (dot-expand x)))
    (fake-expression-expand (place-expand (lambda-expand (rename-arguments (quote-expand (compiler-macroexpand !))))))))

(defun cl-frontend-init ()
  (= *cl-builtins* nil))

(defun cl-expex-initializer (ex)
  (= (expex-argument-filter ex) #'identity
     (expex-setter-filter ex)   #'identity))

(defun cl-sections-before-import ()
  (unless (configuration :exclude-core?)
    (list (. 'cl-core (+ *cl-core*
                         (@ [`(defbuiltin ,_. (&rest x)
                                (apply #',(make-symbol (symbol-name ._.) "CL") x))]
                            +cl-renamed-imports+))))))

(defun make-cl-transpiler ()
  (create-transpiler
      :name                    :common-lisp
      :frontend-only?          t
      :import-variables?       t
      :lambda-export?          nil
      :stack-locals?           nil
      :sections-before-import  #'cl-sections-before-import
      :frontend-init           #'cl-frontend-init
      :own-frontend            #'cl-frontend
      :expex-initializer       #'cl-expex-initializer
      :postprocessor           #'cl-postprocessor
      :configurations          (+ (default-configurations)
                                  '((:exclude-core? . nil)))))

(defvar *cl-transpiler* (make-cl-transpiler))
