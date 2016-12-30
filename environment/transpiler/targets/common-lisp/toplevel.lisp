(defun cl-symbol (x)
  (make-symbol (symbol-name x) "CL"))

(defun cl-frontend-init ()
  (= *cl-builtins* nil))

(defun cl-sections-before-import ()
  (unless (configuration :exclude-core?)
    (list (. 'cl-core (+ (load-string *cl-core*)
                         (@ [`(defbuiltin ,_. (&rest x)
                                (apply #',(cl-symbol ._.) x))]
                         +cl-renamed-imports+))))))

(defun make-cl-transpiler ()
  (create-transpiler
      :name                    :common-lisp
      :output-passes           '((:frontend . :transpiler-macroexpand))
      :disabled-ends           '(:middleend :backend)
      :import-variables?       t
      :lambda-export?          nil
      :stack-locals?           nil
      :sections-before-import  #'cl-sections-before-import
      :frontend-init           #'cl-frontend-init
      :postprocessor           #'make-lambdas
      :configurations          (+ (default-configurations)
                                  '((:exclude-core? . nil)))))

(defvar *cl-transpiler* (make-cl-transpiler))
