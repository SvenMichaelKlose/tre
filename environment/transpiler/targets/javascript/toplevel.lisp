(fn nodejs-prologue ()
  (apply #'+ (@ [format nil "var ~A = require ('~A');~%" _ _]
                (configuration :nodejs-requirements))))

(fn js-prologue ()
  (+ (format nil "// tré revision ~A~%" *tre-revision*)
     (format nil "'use strict';~%")
     (nodejs-prologue)
     (format nil "var _I_ = 0; while (1) {switch (_I_) {case 0: ~%")
     (concat-stringtree (backend-generate-code `((%var ,@(funinfo-vars (global-funinfo))))))))

(fn js-epilogue ()
  (format nil "}break;}~%"))

(fn js-emit-early-defined-functions ()
  (@ [`(push ',_ *functions*)] (memorized-sources)))

(fn js-emit-memorized-sources ()
  (clr (configuration :memorize-sources?))
  (@ [`(%= (slot-value ,_. '__source) (. ,(shared-defun-source _.) (shared-defun-source ._)))]
     (memorized-sources)))

(fn js-sections-before-import ()
  (. (. '*js-core0* (load-string *js-core0*))
     (& (not (configuration :exclude-core?))
         (+ (list (. '*js-core* (load-string *js-core*)))
            (& (assert?)
               (list (. '*js-core-debug-print* (load-string *js-core-debug-print*))))
            (list (. '*js-core1* (load-string *js-core1*))
                  (. 'js-core-stream (load-string (js-core-stream))))
            (& (eq :nodejs (configuration :platform))
               (list (. 'js-core-nodejs (load-string (js-core-nodejs)))))
            (& (eq t *have-environment-tests*)
               (list (. 'environment-tests (make-environment-tests))))))))

(fn js-environment-files ()
  (mapcan [& (| (not ._)
                (member :js ._))
             `((,(+ "environment/" _.)))]
          (reverse *environment-filenames*)))

(fn js-sections-compiler ()
  (!= *js-core-path*
    (+ (list (. 'js-emit-early-defined-functions
                #'js-emit-early-defined-functions)
             (list (+ ! "env-load-stub.lisp")))
       (js-environment-files)
       (list (list (+ ! "late-macro.lisp"))
             (list (+ ! "eval.lisp"))))))

(fn js-sections-after-import ()
  (+ (list (. 'emit-late-symbol-function-assignments
              #'emit-late-symbol-function-assignments)
           (. 'js-emit-memorized-sources
              #'js-emit-memorized-sources))
     (& *have-compiler?*
        (js-sections-compiler))))

(fn js-expex-initializer (ex)
  (= (expex-inline? ex)          #'%slot-value?
     (expex-argument-filter ex)  #'js-argument-filter))

(fn make-javascript-transpiler ()
  (aprog1 (create-transpiler
            :name                     :js
            :prologue-gen             #'js-prologue
            :epilogue-gen             #'js-epilogue
            :sections-before-import   #'js-sections-before-import
            :sections-after-import    #'js-sections-after-import
            :lambda-export?           nil
            :stack-locals?            nil
            :needs-var-declarations?  t
            :enabled-passes           '(:count-tags)
            :identifier-char?         #'c-identifier-char?
            :expex-initializer        #'js-expex-initializer
            :configurations           '((:platform                 . :browser)
                                        (:nodejs-requirements      . nil)
                                        (:rplac-breakpoints        . nil)
                                        (:exclude-core?            . nil)
                                        (:memorize-sources?        . nil)
                                        (:save-sources?            . nil)
                                        (:save-argument-defs-only? . nil)))
    (transpiler-add-functional ! '%js-typeof)))

(var *js-transpiler* (make-javascript-transpiler))
(var *js-separator*  (+ ";" *terpri*))
(var *js-indent*     "    ")
