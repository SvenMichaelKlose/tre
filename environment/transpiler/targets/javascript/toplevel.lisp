(fn nodejs-prologue ()
  (*> #'+ (@ [format nil "var ~A = require ('~A');~%" _ _]
             (configuration :nodejs-requirements))))

(fn js-prologue ()
  (+ (format nil "// tré revision ~A~%" *tre-revision*)
     (format nil "'use strict';~%")
     (nodejs-prologue)
     (format nil "var _I_ = 0; while (1) {switch (_I_) {case 0: ~%")
     (flatten (backend `((%var ,@(funinfo-vars (global-funinfo))))))))

(fn js-epilogue ()
  (format nil "}break;}~%"))

(fn js-emit-early-defined-functions ()
  (@ [`(push ',_ *functions*)] (original-sources)))

(fn js-emit-original-sources ()
  (= (configuration :memorize-sources?) nil)
  (@ [`(%= (slot-value ,_. '__source) (. ,(shared-defun-source _.) (shared-defun-source ._)))]
     (original-sources)))

(fn js-sections-before-import ()
  (. (section-from-string '*js-core-return-value* *js-core-return-value*)
     (& (not (configuration :exclude-core?))
        (+ (… (section-from-string '*js-core0* *js-core0*))
           (& (assert?)
              (… (section-from-string '*js-core-debug-print* *js-core-debug-print*)))
           (… (section-from-string '*js-core1* *js-core1*)
              (section-from-string 'js-core-stream (js-core-stream)))
           (& (eq :nodejs (configuration :platform))
              (… (section-from-string 'js-core-nodejs (js-core-nodejs))))))))

(fn js-sections-compiler ()
  (!= *js-core-path*
    (+ (… (. 'js-emit-early-defined-functions
             #'js-emit-early-defined-functions)
          (… (+ ! "env-load-stub.lisp")))
       (environment-files :js)
       (… (… (+ ! "late-macro.lisp"))
          (… (+ ! "eval.lisp"))))))

(fn js-sections-after-import ()
  (+ (… (. 'emit-late-symbol-function-assignments
           (reverse *late-symbol-function-assignments*))
        (. 'js-emit-original-sources
           #'js-emit-original-sources))
     (?
       *have-compiler?*
         (js-sections-compiler)
       (configuration :include-environment?)
         (js-environment-files))))

(fn make-javascript-transpiler ()
  (aprog1 (create-transpiler
            :name                    :js
            :file-postfix            "js"
            :prologue                #'js-prologue
            :epilogue                #'js-epilogue
            :sections-before-import  #'js-sections-before-import
            :sections-after-import   #'js-sections-after-import
            :needs-var-declarations? t
            :enabled-passes          '(:count-tags)
            :identifier-char?        #'c-identifier-char?
            :inline?                 #'%slot-value?
            :configurations          '((:platform             . :browser)
                                       (:nodejs-requirements  . nil)
                                       (:exclude-core?        . nil)
                                       (:include-environment? . nil)
                                       (:memorize-sources?    . nil)
                                       (:keep-source?         . nil)
                                       (:keep-argdef-only?    . nil)))
    (transpiler-add-functional ! '%js-typeof)))

(var *js-transpiler* (make-javascript-transpiler))
(var *js-separator*  (+ ";" *terpri*))
(var *js-indent*     "    ")
