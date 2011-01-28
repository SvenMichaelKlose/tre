;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(dont-obfuscate apply call)

(cps-exception t)

,(if (transpiler-continuation-passing-style? *current-transpiler*)
     '(defun apply (&rest lst)
        (with (continuer lst.
               fun .lst.
               l (last ..lst)
               args (%nconc (butlast ..lst) l.))
	      (aif fun.tre-exp
               (if fun.tre-cps
		           (!.apply nil (%transpiler-native "[" continuer "," args "]"))
		           (!.apply nil (%transpiler-native "[" args "]")))
    	       (fun.apply nil (list-array (cons continuer args))))))
     '(defun apply (&rest lst)
        (with (fun lst.
               l (last .lst)
               args (%nconc (butlast .lst) l.))
	      (when-debug
	        (unless (function? fun)
		      (error "APPLY: first argument is not a function: ~A" fun))
	        (unless (listp l)
		      (error "APPLY: last argument is not a cell")))
	      (aif fun.tre-exp
		       (!.apply nil (%transpiler-native "[" args "]"))
    	       (fun.apply nil (list-array args))))))

,(unless (transpiler-continuation-passing-style? *current-transpiler*)
   `(defmacro cps-wrap (x)
      x))

(defun cps-return-dummy (&rest x))

(cps-exception nil)

(defun funcall (fun &rest args)
  (apply fun args))
