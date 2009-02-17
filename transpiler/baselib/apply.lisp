;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

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
	  (unless (consp l)
		(error "APPLY: last argument is not a cell")))
    (fun.apply nil
	  (list-array
	    (aif fun.tre-args
             (argument-expand-values fun ! args)
			 args)))))
