;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun js-prologue ()
  (+ (format nil "// tré revision ~A~%" *tre-revision*)
     (format nil ,(fetch-file "environment/transpiler/targets/javascript/environment/native/cps-funcall.js"))
     (format nil "var _I_ = 0; while (1) {switch (_I_) {case 0: ~%")))

(defun js-epilogue ()
  (format nil "}break;}~%"))

(defun js-emit-early-defined-functions ()
  (mapcar ^(push ',_. *defined-functions*)
          (transpiler-memorized-sources *js-transpiler*)))

(defun js-emit-memorized-sources ()
  (clr (transpiler-memorize-sources? *transpiler*))
  (filter ^(%setq (slot-value ,_. '__source) ,(list 'quote ._))
          (transpiler-memorized-sources *transpiler*)))

(defun js-make-decl-gen ()
  #'(()
       (filter [transpiler-generate-code *transpiler* `((%var ,_))]
		       (remove-if [transpiler-emitted-decl? *transpiler* _]
                          (funinfo-vars (transpiler-global-funinfo *transpiler*))))))

(defun js-files-before-deps (tr)
  `((essential-functions-0 . ,*js-base0*)
    ,@(& (not (transpiler-exclude-base? tr))
         `((essential-functions-1 . ,*js-base*)
           ,@(& (transpiler-assert? tr)
                `((debug-printing . ,*js-base-debug-print*)))
           (essential-functions-2 . ,*js-base2*)
           ,@(unless *transpiler-no-stream?*
               `((standard-streams . ,*js-base-stream*)))
           ,@(& (t? *have-environment-tests*)
                `((environment-tests . ,(make-environment-tests))))))))

(defun js-environment-files ()
  (mapcan [unless (in? ._ 'c 'bc)
            `((,(+ "environment/" _.)))]
          (reverse *environment-filenames*)))

(defun js-files-compiler ()
  (alet *js-env-path*
    `((list-of-early-defined-functions . ,#'js-emit-early-defined-functions)
      (,(+ ! "env-load-stub.lisp"))
       ,@(js-environment-files)
      (,(+ ! "late-macro.lisp"))
      (,(+ ! "eval.lisp")))))

(defun js-files-after-deps ()
  `((late-symbol-function-assignments . ,#'emit-late-symbol-function-assignments)
    (memorized-source-emitter . ,#'js-emit-memorized-sources)
    ,@(& *have-compiler?*
         (js-files-compiler))))

(defun js-transpile (sources &key (transpiler nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil))
  (dolist (i '(%cons cons %symbol symbol))
    (transpiler-add-cps-exception transpiler i))
  (target-transpile transpiler
                    :prologue-gen        #'js-prologue
                    :epilogue-gen        #'js-epilogue
                    :decl-gen            (js-make-decl-gen)
                    :files-before-deps   (js-files-before-deps transpiler)
                    :files-after-deps    (+ (js-files-after-deps)
                                            sources)
                    :files-to-update     files-to-update
                    :obfuscate?          obfuscate?
                    :print-obfuscations? print-obfuscations?))
