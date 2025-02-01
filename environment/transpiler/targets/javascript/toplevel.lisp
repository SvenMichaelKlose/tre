(fn nodejs-prologue ()
  (*> #'+ (@ [format nil "var ~A = require ('~A');~%" _ _]
             (configuration :nodejs-requirements))))

(fn js-prologue ()
  (+ (format nil "// tré revision ~A~%" *tre-revision*)
     (format nil "'use strict';~%")
     (nodejs-prologue)
     (format nil "var _I_ = 0; while (1) {switch (_I_) {case 0: ~%")
     (flatten (backend-generate-code `((%var ,@(funinfo-vars (global-funinfo))))))))

(fn js-epilogue ()
  (format nil "}break;}~%"))

(fn js-emit-early-defined-functions ()
  (@ [`(push ',_ *functions*)] (memorized-sources)))

(fn js-emit-memorized-sources ()
  (clr (configuration :memorize-sources?))
  (@ [`(%= (slot-value ,_. '__source) (. ,(shared-defun-source _.) (shared-defun-source ._)))]
     (memorized-sources)))

(fn js-sections-before-import ()
  (. (section-from-string '*js-core0* *js-core0*)
     (& (not (configuration :exclude-core?))
        (+ (… (section-from-string '*js-core* *js-core*))
           (& (assert?)
              (… (section-from-string '*js-core-debug-print* *js-core-debug-print*)))
           (… (section-from-string '*js-core1* *js-core1*)
              (section-from-string 'js-core-stream (js-core-stream)))
           (& (eq :nodejs (configuration :platform))
              (… (section-from-string 'js-core-nodejs (js-core-nodejs))))))))

(fn js-environment-files ()
  (+@ [& (| (not ._)
            (member :js ._))
         `((,(+ "environment/" _.)))]
      (reverse *environment-filenames*)))

(fn js-sections-compiler ()
  (!= *js-core-path*
    (+ (… (. 'js-emit-early-defined-functions
             #'js-emit-early-defined-functions)
          (… (+ ! "env-load-stub.lisp")))
       (js-environment-files)
       (… (… (+ ! "late-macro.lisp"))
          (… (+ ! "eval.lisp"))))))

(fn js-sections-after-import ()
  (+ (… (. 'emit-late-symbol-function-assignments
           #'emit-late-symbol-function-assignments)
        (. 'js-emit-memorized-sources
           #'js-emit-memorized-sources))
     (& *have-compiler?*
        (js-sections-compiler))))

(fn make-javascript-transpiler ()
  (aprog1 (create-transpiler
            :name                     :js
            :file-postfix             "js"
            :prologue-gen             #'js-prologue
            :epilogue-gen             #'js-epilogue
            :sections-before-import   #'js-sections-before-import
            :sections-after-import    #'js-sections-after-import
            :lambda-export?           nil
            :stack-locals?            nil
            :needs-var-declarations?  t
            :enabled-passes           '(:count-tags)
            :identifier-char?         #'c-identifier-char?
            :inline?                  #'%slot-value?
            :argument-filter          #'js-argument-filter
            :configurations           '((:platform            . :browser)
                                        (:nodejs-requirements . nil)
                                        (:rplac-breakpoints   . nil)
                                        (:exclude-core?       . nil)
                                        (:memorize-sources?   . nil)
                                        (:keep-source?        . nil)
                                        (:keep-argdef-only?   . nil)))
    (transpiler-add-functional ! '%js-typeof)))

(var *js-transpiler* (make-javascript-transpiler))
(var *js-separator*  (+ ";" *terpri*))
(var *js-indent*     "    ")
