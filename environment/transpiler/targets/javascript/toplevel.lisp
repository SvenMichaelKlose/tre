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
          (transpiler-memorized-sources *js-transpiler*)))

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

(defun js-sections-before-deps (tr)
  `((essential-functions-0 . ,*js-base0*)
    ,@(& (not (transpiler-exclude-base? tr))
         `((essential-functions-1 . ,*js-base*)
           ,@(& (transpiler-assert? tr)
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

(defun js-sections-after-deps (tr)
  `((late-symbol-function-assignments . ,#'emit-late-symbol-function-assignments)
    (memorized-source-emitter . ,#'js-emit-memorized-sources)
    ,@(& *have-compiler?*
         (js-sections-compiler))))

(defun js-ending-sections (tr)
  );`((funinfo-inits . ,#'gen-funinfo-inits)))
