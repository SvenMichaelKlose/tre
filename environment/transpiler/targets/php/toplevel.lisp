;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defvar *nil-symbol-name* nil)

(defun php-gen-funref-wrapper (out)
  (princ ,(concat-stringtree
		      (with-open-file i (open "environment/transpiler/targets/php/funref.php"
							 		  :direction 'input)
			  	(read-all-lines i)))
		 out))

(defun php-transpile-prepare (tr &key (import-universe? nil))
  (with-string-stream out
    (when import-universe?
      (transpiler-import-universe tr))
    (transpiler-add-wanted-function tr 'array-copy)
    (format out "<?php~%$NULL=NULL;~%$t=True;~%")
    (format out "function & __w ($x) { return $x; }~%")
    (php-gen-funref-wrapper out)))

(defun php-transpile (files &key (obfuscate? nil)
                                (print-obfuscations? nil)
                                (files-to-update nil)
						   		(make-updater nil))
  (let tr *php-transpiler*
    (transpiler-reset tr)
    (target-transpile-setup tr :obfuscate? obfuscate?)
    (when (transpiler-lambda-export? tr)
      (transpiler-add-wanted-function tr 'array-copy))
	(concat-stringtree
		(php-transpile-prepare tr)
    	(target-transpile tr
    	 	:files-before-deps
			    (append (list (cons 'text *php-base*))
;		 		  		(when *transpiler-log*
;				   	  	  (list (cons 'text *php-base-debug-print*)))
				  	    (list (cons 'text *php-base2*)))
		  	:files-after-deps
				(append (when (eq t *have-environment-tests*)
				   	  	  (list (cons 'text (make-environment-tests))))
		 		 		(mapcar (fn list _) files))
		 	:dep-gen
		     	#'(()
				  	(transpiler-import-from-environment tr))
			:decl-gen
		     	#'(())
			:files-to-update files-to-update
			:make-updater make-updater
			:print-obfuscations? print-obfuscations?))))
