(fn cl-symbol (x)
  (make-symbol (symbol-name x) "CL"))

(fn cl-frontend-init ()
  (= *cl-builtins* nil))

(fn cl-sections-before-import ()
  (unless (configuration :exclude-core?)
    (… (. 'cl-core (+ (read-from-string *cl-core*)
                      (@ [`(defbuiltin ,_. (&rest x)
                             (*> #',(cl-symbol ._.) x))]
                         +cl-renamed-imports+))))))

(fn make-cl-transpiler ()
  (create-transpiler
      :name                    :common-lisp
      :file-postfix            "lisp"
      :output-passes           '((:frontend . :transpiler-macroexpand))
      :disabled-passes         '(:expand-literal-characters)
      :disabled-ends           '(:middleend :backend)
      :import-variables?       t
      :lambda-export?          nil
      :stack-locals?           nil
      :sections-before-import  #'cl-sections-before-import
      :frontend-init           #'cl-frontend-init
      :postprocessor           #'make-lambdas
      :configurations          '((:save-sources?)
                                 (:save-argument-defs-only?)
                                 (:exclude-core?)
                                 (:memorize-sources? . t))))

(var *cl-transpiler* (make-cl-transpiler))
