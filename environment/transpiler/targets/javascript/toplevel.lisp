; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun nodejs-prologue ()
   (apply #'+ (filter [format nil "var ~A = require ('~A');~%" _ _]
                      (configuration 'nodejs-requirements))))

(defun js-prologue ()
  (+ (format nil "// tré revision ~A~%" *tre-revision*)
     (nodejs-prologue)
     (& (cps-transformation?)
        (format nil ,(fetch-file "environment/transpiler/targets/javascript/environment/native/cps.js")))
     (format nil "var _I_ = 0; while (1) {switch (_I_) {case 0: ~%")))

(defun js-epilogue ()
  (format nil "}break;}~%"))

(defun js-emit-early-defined-functions ()
  (mapcar [`(push ',_ *functions*)]
          (memorized-sources)))

(defun js-emit-memorized-sources ()
  (clr (memorize-sources?))
  (filter [`(%= (slot-value ,_. '__source) ,(list 'quote ._))]
          (memorized-sources)))

(defun js-var-decls ()
  (filter [generate-code `((%var ,_))]
          (remove-if #'emitted-decl?
                     (funinfo-vars (global-funinfo)))))

(defun gen-funinfo-init ()
  `(push '',(compiled-list `(,x. ,(funinfo-args .x))) *application-funinfos*))

(defun gen-funinfo-inits ()
  (filter #'gen-funinfo-init (hash-alist (funinfos))))

(defun js-sections-before-deps ()
  `((essential-functions-0 . ,*js-base0*)
    ,@(& (not (exclude-base?))
         `((essential-functions-1 . ,*js-base*)
           ,@(& (assert?)
                `((debug-printing . ,*js-base-debug-print*)))
           (essential-functions-2 . ,*js-base2*)
           (standard-streams . ,(js-base-stream))
           ,@(& (eq 'nodejs (configuration 'environment))
                `((nodejs-base . ,(js-base-nodejs))))
           ,@(& (t? *have-environment-tests*)
                `((environment-tests . ,(make-environment-tests))))))))

(defun js-environment-files ()
  (mapcan [& (in? ._ nil 'js)
            `((,(+ "environment/" _.)))]
          (reverse *environment-filenames*)))

(defun js-sections-compiler ()
  (alet *js-env-path*
    `((list-of-early-defined-functions . ,#'js-emit-early-defined-functions)
      (,(+ ! "env-load-stub.lisp"))
      ,@(js-environment-files)
      (,(+ ! "late-macro.lisp"))
      (,(+ ! "eval.lisp")))))

(defun js-sections-after-deps ()
  `((late-symbol-function-assignments . ,#'emit-late-symbol-function-assignments)
    (memorized-source-emitter . ,#'js-emit-memorized-sources)
    ,@(& *have-compiler?*
         (js-sections-compiler))))

(defun js-ending-sections (tr)
  );`((funinfo-inits . ,#'gen-funinfo-inits)))

(defun js-expex-initializer (ex)
  (= (expex-inline? ex)         #'%slot-value?
     (expex-argument-filter ex) #'js-argument-filter))

(defun make-javascript-transpiler-0 ()
  (create-transpiler
      :name                     'js
      :prologue-gen             #'js-prologue
      :epilogue-gen             #'js-epilogue
      :decl-gen                 #'js-var-decls
      :sections-before-deps     #'js-sections-before-deps
      :sections-after-deps      #'js-sections-after-deps
	  :lambda-export?           nil
	  :stack-locals?            nil
	  :needs-var-declarations?  t
      :count-tags?              t
	  :identifier-char?         #'c-identifier-char?
	  :literal-converter        #'expand-literal-characters
      :expex-initializer        #'js-expex-initializer
      :ending-sections          #'js-ending-sections
      :configurations           '((environment       . browser)
                                  (nodejs-requirements . nil)
                                  (rplac-breakpoints . nil))))

(defun make-javascript-transpiler ()
  (aprog1 (make-javascript-transpiler-0)
    (transpiler-add-plain-arg-funs ! *builtins*)))

(defvar *js-transpiler* (copy-transpiler (make-javascript-transpiler)))
(| *default-transpiler*
   (= *default-transpiler* *js-transpiler*))
(defvar *js-separator*  (+ ";" *newline*))
(defvar *js-indent*     "    ")
