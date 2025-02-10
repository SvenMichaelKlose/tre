(fn cl-frontend-init ()
  (= *cl-builtins* nil))

(fn cl-symbol (x)
  (make-symbol (symbol-name x) "CL"))

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
      :disabled-ends           '(:middleend :backend)
      :disabled-passes         '(:expand-literal-characters)
      :output-passes           '((:frontend . :transpiler-macroexpand))
      :frontend-init           #'cl-frontend-init
      :sections-before-import  #'cl-sections-before-import
      :postprocessor           #'make-lambdas
      :configurations          '((:keep-source?)
                                 (:keep-argdef-only?)
                                 (:exclude-core?)
                                 (:memorize-sources? . t))))

(var *cl-transpiler* (make-cl-transpiler))
