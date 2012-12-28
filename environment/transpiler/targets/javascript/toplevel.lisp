;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun js-transpile-prologue ()
  (format nil "    var _I_ = 0; while (1) {switch (_I_) {case 0: ~%"))

(defun js-transpile-epilogue ()
  (format nil "    }break;}~%"))

(defun js-gen-funref-wrapper ()
  ,(fetch-file "environment/transpiler/targets/javascript/funref.js"))

(defun js-transpile-pre (tr)
  (+ (js-transpile-prologue)
     (? (transpiler-lambda-export? tr)
        (js-gen-funref-wrapper)
        "")))

(defun js-transpile-post ()
  (js-transpile-epilogue))

(defun js-emit-early-defined-functions ()
  (mapcar ^(push ,(list 'quote _.) *defined-functions*) (transpiler-memorized-sources *js-transpiler*)))

(defun js-make-decl-gen (tr)
  #'(()
      (filter [transpiler-generate-code tr (list `(%var ,_))]
		      (funinfo-env (transpiler-global-funinfo tr)))))

(defun js-files-before-deps ()
  (+ (list (cons 't1 *js-base*))
     (& *transpiler-assert*
        (list (cons 't2 *js-base-debug-print*)))
     (list (cons 't3 *js-base2*))
     (unless *transpiler-no-stream?*
       (list (cons 't4 *js-base-stream*)))
     (& (eq t *have-environment-tests*)
        (list (cons 't5 (make-environment-tests))))))

(defun js-files-compiler ()
  (+ (list (cons 'list-of-defined-functions #'js-emit-early-defined-functions)
           (list (+ *js-env-path* "env-load-stub.lisp")))
     (mapcan [unless (eq 'c ._)
               (list (list (string-concat "environment/" _.)))]
             (reverse *environment-filenames*))
     (list (list (+ *js-env-path* "late-macro.lisp"))
           (list (+ *js-env-path* "eval.lisp")))))

(defun js-files-after-deps ()
  (+ (list (cons 'late-symbol-function-assignments #'emit-late-symbol-function-assignments)
           (cons 'memorized-source-emitter #'js-emit-memorized-sources))
     (& *have-compiler?*
        (js-files-compiler))))

(defun js-transpile (sources &key (transpiler nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil))
  (let tr transpiler
    (& (transpiler-lambda-export? tr)
       (transpiler-add-wanted-function tr 'array-copy))
	(string-concat
		(js-transpile-pre tr)
    	(target-transpile tr :files-before-deps (js-files-before-deps)
		  	                 :files-after-deps  (+ (js-files-after-deps) sources)
		 	                 :dep-gen           #'(()
				  	                                (transpiler-import-from-environment tr))
			                 :decl-gen            (js-make-decl-gen tr)
                             :files-to-update     files-to-update
                             :obfuscate?          obfuscate?
			                 :print-obfuscations? print-obfuscations?)
    	(js-transpile-post))))
