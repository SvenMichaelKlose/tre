;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defun js-transpile-prologue ()
  (format nil "    var _I_ = 0; while (1) {switch (_I_) {case 0: ~%"))

(defun js-transpile-epilogue ()
  (format nil "    }break;}~%"))

(defun js-gen-funref-wrapper ()
  ,(concat-stringtree
      (with-open-file i (open "environment/transpiler/targets/javascript/funref.js" :direction 'input)
	  	(read-all-lines i))))

(defun js-transpile-pre (tr)
  (when (transpiler-lambda-export? tr)
    (js-gen-funref-wrapper)))

(defun js-transpile-post ()
  (js-transpile-epilogue))

(defun js-emit-early-defined-functions ()
  (mapcar (fn `(push ,(list 'quote _.) *defined-functions*)) (transpiler-memorized-sources *js-transpiler*)))

(defun js-make-decl-gen (tr)
  #'(()
      (with-queue decls
		(dolist (i (funinfo-env (transpiler-global-funinfo tr)))
          (unless (transpiler-emitted-decl? tr i)
       	    (enqueue decls (transpiler-emit-code tr (list `(%var ,i))))
            (transpiler-add-emitted-decl tr i)))
        (enqueue decls (js-transpile-prologue))
	    (queue-list decls))))

(defun js-files-before-deps ()
  (append (list (cons 't1 *js-base*))
          (when *transpiler-assert*
            (list (cons 't2 *js-base-debug-print*)))
          (list (cons 't3 *js-base2*))
          (unless *transpiler-no-stream?*
            (list (cons 't4 *js-base-stream*)))
          (when (eq t *have-environment-tests*)
            (list (cons 't5 (make-environment-tests))))))

(defun js-files-after-deps ()
  (append (list (cons 'late-symbol-function-assignments #'emit-late-symbol-function-assignments)
                (cons 'memorized-source-emitter #'js-emit-memorized-sources))
          (when *have-compiler?*
            (append (list (cons 'list-of-defined-functions #'js-emit-early-defined-functions)
                          (list (+ *js-env-path* "env-load-stub.lisp")))
                    (mapcan (fn unless ._
                                 (list (list (string-concat "environment/" _.))))
                            (reverse *environment-filenames*))
                    (list (list (+ *js-env-path* "late-macro.lisp"))
                          (list (+ *js-env-path* "eval.lisp")))))))

(defun js-transpile (sources &key (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil))
  (let tr *js-transpiler*
    (when (transpiler-lambda-export? tr)
      (transpiler-add-wanted-function tr 'array-copy))
	(string-concat
		(js-transpile-pre tr)
    	(target-transpile tr :files-before-deps (js-files-before-deps)
		  	                 :files-after-deps (append (js-files-after-deps) sources)

		 	                 :dep-gen #'(()
				  	                      (transpiler-import-from-environment tr))
			                 :decl-gen (js-make-decl-gen tr)
                             :files-to-update files-to-update
                             :obfuscate? obfuscate?
			                 :print-obfuscations? print-obfuscations?)
    	(js-transpile-post))))
