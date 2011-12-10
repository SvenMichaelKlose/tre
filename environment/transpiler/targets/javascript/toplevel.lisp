;;;;; tré - Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun js-transpile-prologue (tr)
  (format nil (+ "    var _I_ = 0; while (1) {switch (_I_) {case 0: ~%"
  			     "    var ~A;~%")
			  (transpiler-symbol-string tr (transpiler-obfuscate-symbol tr '*CURRENT-FUNCTION*))))

(defun js-transpile-epilogue ()
  (format nil "    }break;}~%"))

(defun js-gen-funref-wrapper ()
  ,(concat-stringtree
      (with-open-file i (open "environment/transpiler/targets/javascript/funref.js" :direction 'input)
	  	(read-all-lines i))))

(defun js-transpile-pre (tr)
  (concat-stringtree (js-transpile-prologue tr)
                     (when (transpiler-lambda-export? tr)
                       (js-gen-funref-wrapper))))

(defun js-transpile-post ()
  (js-transpile-epilogue))

(defun js-make-decl-gen (tr)
  #'(()
      (with-queue decls
        (dolist (i (funinfo-env (transpiler-global-funinfo tr)) (queue-list decls))
          (enqueue decls (transpiler-emit-code tr (list `(%var ,i))))))))

(defun js-emit-early-defined-functions ()
  (mapcar (fn `(push ,(list 'quote _.) *defined-functions*)) (transpiler-memorized-sources *js-transpiler*)))

(defun js-transpile (files &key (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil))
  (let tr *js-transpiler*
    (unless files-to-update
      (transpiler-reset tr)
      (target-transpile-setup tr :obfuscate? obfuscate?))
    (when (transpiler-lambda-export? tr)
      (transpiler-add-wanted-function tr 'array-copy))
	(concat-stringtree
		(js-transpile-pre tr)
    	(target-transpile tr :files-before-deps
			                     (append (list (cons 't1 *js-base*))
		 		  		                 (when *transpiler-assert*
				   	  	                   (list (cons 't2 *js-base-debug-print*)))
				  	                     (list (cons 't3 *js-base2*))
                                         (unless *transpiler-no-stream?*
				  	                       (list (cons 't4 *js-base-stream*)))
				                         (when (eq t *have-environment-tests*)
				   	  	                   (list (cons 't5 (make-environment-tests)))))
		  	                 :files-after-deps
 		                         (append (list (cons 'late-symbol-function-assignments #'emit-late-symbol-function-assignments)
 		                                       (cons 'memorized-source-emitter #'js-emit-memorized-sources)
                                               (when *have-compiler?*
 		                                         (cons 'list-of-defined-functions #'js-emit-early-defined-functions)))
                                         (mapcar #'list files))
		 	                 :dep-gen #'(()
				  	                      (transpiler-import-from-environment tr))
			                 :decl-gen #'(()
                                           (with-queue decls
					  		                 (dolist (i (funinfo-env (transpiler-global-funinfo tr)) (queue-list decls))
       				                           (enqueue decls (transpiler-emit-code tr (list `(%var ,i)))))))
			                 :files-to-update files-to-update
			                 :print-obfuscations? print-obfuscations?)
    	(js-transpile-post))))
