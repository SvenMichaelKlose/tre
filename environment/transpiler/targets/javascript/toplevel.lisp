; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@hugbox.org>

(defun nodejs-prologue ()
   (apply #'+ (@ [format nil "var ~A = require ('~A');~%" _ _]
                 (configuration :nodejs-requirements))))

(defun js-prologue ()
  (+ (format nil "// tré revision ~A~%" *tre-revision*)
     (nodejs-prologue)
     (& (enabled-pass? :cps)
        (format nil ,(fetch-file "environment/transpiler/targets/javascript/core/native/cps.js")))
     (format nil "var _I_ = 0; while (1) {switch (_I_) {case 0: ~%")))

(defun js-epilogue ()
  (format nil "}break;}~%"))

(defun js-emit-early-defined-functions ()
  (@ [`(push ',_ *functions*)] (memorized-sources)))

(defun js-emit-memorized-sources ()
  (clr (configuration :memorize-sources?))
  (@ [`(%= (slot-value ,_. '__source) ,(list 'quote ._))]
     (memorized-sources)))

(defun js-var-decls ()
  (@ [generate-code `((%var ,_))]
     (remove-if #'emitted-decl? (funinfo-vars (global-funinfo)))))

;(defun gen-funinfo-init ()
;  `(push ',(compiled-list `(,x. ,(funinfo-args .x))) *application-funinfos*))

;(defun gen-funinfo-inits ()
;  (@ #'gen-funinfo-init (hash-alist (funinfos))))

(defun js-sections-before-import ()
  (. (. '*js-core0* *js-core0*)
     (& (not (configuration :exclude-core?))
         (+ (list (. '*js-core* *js-core*))
            (& (assert?)
               (list (. '*js-core-debug-print* *js-core-debug-print*)))
            (list (. '*js-core1* *js-core1*)
                  (. 'js-core-stream (js-core-stream)))
            (& (eq :nodejs (configuration :platform))
               (list (. 'js-core-nodejs (js-core-nodejs))))
            (& (t? *have-environment-tests*)
               (list (. 'environment-tests (make-environment-tests))))))))

(defun js-environment-files ()
  (mapcan [& (in? ._ nil 'js)
            `((,(+ "environment/" _.)))]
          (reverse *environment-filenames*)))

(defun js-sections-compiler ()
  (alet *js-core-path*
    (+ (list (. 'list-of-early-defined-functions #'js-emit-early-defined-functions)
             (list (+ ! "env-load-stub.lisp")))
       (js-environment-files)
       (list (list (+ ! "late-macro.lisp"))
             (list (+ ! "eval.lisp"))))))

(defun js-sections-after-import ()
  (+ (list (. 'late-symbol-function-assignments #'emit-late-symbol-function-assignments)
           (. 'memorized-source-emitter #'js-emit-memorized-sources))
     (& *have-compiler?*
        (js-sections-compiler))))

(defun js-ending-sections ()
  );`((funinfo-inits . ,#'gen-funinfo-inits)))

(defun js-expex-initializer (ex)
  (= (expex-inline? ex)         #'%slot-value?
     (expex-argument-filter ex) #'js-argument-filter))

(defun make-javascript-transpiler-0 ()
  (create-transpiler
      :name                     :js
      :prologue-gen             #'js-prologue
      :epilogue-gen             #'js-epilogue
      :decl-gen                 #'js-var-decls
      :sections-before-import   #'js-sections-before-import
      :sections-after-import    #'js-sections-after-import
	  :lambda-export?           nil
	  :stack-locals?            nil
	  :needs-var-declarations?  t
      :enabled-passes           '(:count-tags)
	  :identifier-char?         #'c-identifier-char?
	  :literal-converter        #'expand-literal-characters
      :expex-initializer        #'js-expex-initializer
      :ending-sections          #'js-ending-sections
      :configurations           '((:platform                 . :browser)
                                  (:nodejs-requirements      . nil)
                                  (:rplac-breakpoints        . nil)
                                  (:exclude-core?            . nil)
                                  (:memorize-sources?        . nil)
                                  (:save-sources?            . nil)
                                  (:save-argument-defs-only? . nil))))

(defun make-javascript-transpiler ()
  (aprog1 (make-javascript-transpiler-0)
    (transpiler-add-plain-arg-funs ! *builtins*)))

(defvar *js-transpiler* (make-javascript-transpiler))
(defvar *js-separator*  (+ ";" *newline*))
(defvar *js-indent*     "    ")
