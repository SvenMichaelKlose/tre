;;;;; tré – Copyright (c) 2008–2010,2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate apply call)

;(cps-exception t)

(defun cps-apply (continuer &rest lst)
  (with (fun lst.
         l (last .lst)
         args (%nconc (butlast .lst) l.))
    (!? fun.tre-exp
        (? fun.tre-cps
	       (!.apply nil (%transpiler-native "[" continuer "," args "]"))
	       (continuer (!.apply nil (%transpiler-native "[" args "]"))))
        (? fun.tre-cps
           (fun.apply nil (list-array (cons continuer args)))
           (continuer (fun.apply nil (list-array (cons continuer args))))))))

(defun apply (&rest lst)
  (with (fun lst.
         l (last .lst)
         args (%nconc (butlast .lst) l.))
    (when-debug
      (unless (function? fun)
	    (error "APPLY: first argument is not a function: ~A" fun))
	  (unless (list? l)
	    (error "APPLY: last argument is not a list")))
    (!? fun.tre-exp
        (!.apply nil (%transpiler-native "[" args "]"))
     (fun.apply nil (list-array args)))))

(dont-inline cps-wrap)
(defun cps-wrap  (x) x)

(defun cps-return-dummy (&rest x))

;(cps-exception t)

(defun funcall (fun &rest args)
  (apply fun args))
