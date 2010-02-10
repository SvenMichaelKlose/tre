;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(dont-obfuscate apply call)

;; Call function with expanded arguments.
;;
;; Get arguments as a list, call the default argument expander
;; and copies the result into a new ECMAScript array to call
;; the native apply().
(defun apply (fun &rest lst)
  (with (l (last lst)
  		 args (%nconc (butlast lst)
					  l.))
	(when-debug
	  (unless (functionp fun)
		(error "APPLY: first argument is not a function: ~A" fun))
	  (unless (listp l)
		(error "APPLY: last argument is not a cell")))
	(aif fun.tre-exp
		 (!.apply nil (%transpiler-native "[" args "]"))
    	 (fun.apply nil
	  		   	    (list-array
				        ; XXX Doesn't detect if function wants no arguments.
	    		        (if fun.tre-args
             		        (argument-expand-values fun fun.tre-args args)
			 		        args))))))
