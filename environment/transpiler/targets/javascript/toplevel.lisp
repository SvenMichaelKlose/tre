;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

(defun js-transpile-prologue (tr)
  (format nil (+ "    var _I_ = 0; while (1) {switch (_I_) {case 0: ~%"
  			     "    var ~A;~%")
			  (transpiler-symbol-string tr
				  (transpiler-obfuscate-symbol tr '*CURRENT-FUNCTION*))))

(defun js-transpile-epilogue ()
  (format nil "    }break;}~%"))

(defun js-gen-funref-wrapper ()
  ,(concat-stringtree
      (with-open-file i
		  (open "environment/transpiler/targets/javascript/funref.js"
				:direction 'input)
	  	(read-all-lines i))))

(defun js-transpile-pre (tr)
  (concat-stringtree
      (js-transpile-prologue tr)
      (when (transpiler-lambda-export? tr)
        (js-gen-funref-wrapper))))

(defun js-transpile-post ()
  (js-transpile-epilogue))

(defun js-transpile (files &key (obfuscate? nil)
                                (print-obfuscations? nil)
                                (files-to-update nil)
						   		(make-updater nil))
  (let tr *js-transpiler*
    (transpiler-reset tr)
    (target-transpile-setup tr :obfuscate? obfuscate?)
    (when (transpiler-lambda-export? tr)
      (transpiler-add-wanted-function tr 'array-copy))
	(concat-stringtree
		(js-transpile-pre tr)
    	(target-transpile tr
    	 	:files-before-deps
			    (append (list (cons 'text *js-base*))
		 		  		(when *transpiler-log*
				   	  	  (list (cons 'text *js-base-debug-print*)))
				  	    (list (cons 'text *js-base2*)))
		  	:files-after-deps
				(append (when (eq t *have-environment-tests*)
				   	  	  (list (cons 'text (make-environment-tests))))
		 		 		(mapcar (fn list _) files))
		 	:dep-gen
		     	#'(()
				  	(transpiler-import-from-environment tr))
			:decl-gen
		     	#'(()
       				(mapcar (fn transpiler-emit-code tr (list `(%var ,_)))
					  		(funinfo-env *global-funinfo*)))
			:files-to-update files-to-update
			:make-updater make-updater
			:print-obfuscations? print-obfuscations?)
    	(js-transpile-post))))

(defun js-retranspile (files-to-update)
  (let tr *js-transpiler*
	(concat-stringtree (js-transpile-pre tr)
    				   (funcall *updater* tr files-to-update)
    				   (js-transpile-post))))
