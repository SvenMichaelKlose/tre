;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defvar *nil-symbol-name* nil)

(defun php-print-native-environment (out)
  (princ ,(concat-stringtree
              (mapcar (fn with-open-file i (open (+ "environment/transpiler/targets/php/environment/native/"
                                                    _ ".php")
						 	                     :direction 'input)
			  	           (read-all-lines i))
                      '("reference" "character" "cons" "funref" "symbol")))
		 out))

(defun php-transpile-prepare (tr &key (import-universe? nil))
  (with-string-stream out
    (when import-universe?
      (transpiler-import-universe tr))
    (format out "<?php~%")
    (php-print-native-environment out)))

(defun php-transpile (files &key (obfuscate? nil)
                                (print-obfuscations? nil)
                                (files-to-update nil)
						   		(make-updater nil))
  (let tr *php-transpiler*
    (transpiler-reset tr)
    (target-transpile-setup tr :obfuscate? obfuscate?)
    (transpiler-add-defined-variable tr '*KEYWORD-PACKAGE*)
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
                #'(()
                     (transpiler-transpile tr                                                                       
                         (transpiler-sighten tr
                             (transpiler-compiled-inits tr))))
			:files-to-update files-to-update
			:make-updater make-updater
			:print-obfuscations? print-obfuscations?))))
