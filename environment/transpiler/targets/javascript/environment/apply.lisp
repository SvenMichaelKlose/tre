;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(dont-obfuscate apply call)

(defun apply (fun &rest lst)
  (with (l (last lst)
  		 args (%nconc (butlast lst) l.))
	(when-debug
	  (unless (functionp fun)
		(error "APPLY: first argument is not a function: ~A" fun))
	  (unless (listp l)
		(error "APPLY: last argument is not a cell")))
;	(awhen fun.tre-args
;		(argument-expand 'runtime-argexp ! args))
	(aif fun.tre-exp
		 (!.apply nil (%transpiler-native "[" args "]"))
    	 (fun.apply nil (list-array args)))))
