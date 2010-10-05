;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(dont-obfuscate apply call)

,(if (transpiler-continuation-passing-style? *current-transpiler*)
     '(defun apply (&rest lst)
        (with (continuer lst.
               fun .lst.
               l (last ..lst)
               args (%nconc (butlast ..lst) l.))
          (when fun.tre-cps
            (push! continuer args))
	      (when-debug
	        (unless (functionp fun)
		      (error "APPLY: first argument is not a function: ~A" fun))
	        (unless (listp l)
		      (error "APPLY: last argument is not a cell")))
	      (aif fun.tre-exp
		       (!.apply nil (%transpiler-native "[" args "]"))
    	       (fun.apply nil (list-array args)))))
     '(defun apply (&rest lst)
        (with (fun lst.
               l (last .lst)
               args (%nconc (butlast .lst) l.))
	      (when-debug
	        (unless (functionp fun)
		      (error "APPLY: first argument is not a function: ~A" fun))
	        (unless (listp l)
		      (error "APPLY: last argument is not a cell")))
	      (aif fun.tre-exp
		       (!.apply nil (%transpiler-native "[" args "]"))
    	       (fun.apply nil (list-array args))))))

(cps-exception nil)

(defun funcall (fun &rest args)
  (apply fun args))

(cps-exception t)

