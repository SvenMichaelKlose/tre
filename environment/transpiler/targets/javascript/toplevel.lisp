;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun js-transpile-prologue (tr)
  (+ (format nil "// tré revision ~A~%" *tre-revision*)
     (format nil "var _I_ = 0; while (1) {switch (_I_) {case 0: ~%")
     (? (transpiler-lambda-export? tr)
        ,(fetch-file "environment/transpiler/targets/javascript/environment/native/closure.js")
        "")))

(defun js-transpile-epilogue ()
  (format nil "}break;}~%"))

(defun js-emit-early-defined-functions (tr)
  (mapcar ^(push ',_. *defined-functions*)
          (transpiler-memorized-sources tr)))

(defun js-emit-memorized-sources (tr)
  (clr (transpiler-memorize-sources? tr))
  (filter ^(%setq (slot-value ,_. '__source) ,(list 'quote ._))
          (transpiler-memorized-sources tr)))

(defun js-make-decl-gen (tr)
  #'(()
       (filter [transpiler-generate-code tr `((%var ,_))]
		       (remove-if [transpiler-emitted-decl? tr _]
                          (funinfo-vars (transpiler-global-funinfo tr))))))

(defun js-files-before-deps (tr)
  (+ `((t1 . ,*js-base*))
     (& (transpiler-assert? tr)
        `((t2 . ,*js-base-debug-print*)))
     `((t3 . ,*js-base2*))
     (unless *transpiler-no-stream?*
       `((t4 . ,*js-base-stream*)))
     (& (eq t *have-environment-tests*)
        `((t5 . ,(make-environment-tests))))))

(defun js-files-compiler (tr)
  (+ `((list-of-early-defined-functions . ,#'(()
                                                (js-emit-early-defined-functions tr)))
       (,(+ *js-env-path* "env-load-stub.lisp")))
     (mapcan [unless (eq 'c ._)
               `((,(+ "environment/" _.)))]
             (reverse *environment-filenames*))
     `((,(+ *js-env-path* "late-macro.lisp"))
       (,(+ *js-env-path* "eval.lisp")))))

(defun js-files-after-deps (tr)
  (+ `((late-symbol-function-assignments . ,#'emit-late-symbol-function-assignments)
       (memorized-source-emitter . ,#'(()
                                         (js-emit-memorized-sources tr))))
     (& *have-compiler?*
        (js-files-compiler tr))))

(defun js-transpile (sources &key (transpiler nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil))
  (let tr transpiler
    (& (transpiler-lambda-export? tr)
       (transpiler-add-wanted-function tr 'array-copy))
    (+ (js-transpile-prologue tr)
       (target-transpile tr :decl-gen            (js-make-decl-gen tr)
                            :files-before-deps   (js-files-before-deps tr)
                            :dep-gen             #'(()
                                                      (transpiler-import-from-environment tr))
                            :files-after-deps    (+ (js-files-after-deps tr)
                                                    sources)
                            :files-to-update     files-to-update
                            :obfuscate?          obfuscate?
                            :print-obfuscations? print-obfuscations?)
       (js-transpile-epilogue))))
