;;;;; tré – Copyright (c) 2008–2010,2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate apply call)

(defun cps-apply (continuer &rest lst)
  (with (fun  lst.
         l    (last .lst)
         args (%nconc (butlast .lst) l.))
    (!? fun.tre-exp
        (? fun.tre-cps
	       (!.apply nil (%%native "[" continuer "," args "]"))
	       (continuer (!.apply nil (%%native "[" args "]"))))
        (? fun.tre-cps
           (fun.apply nil (list-array (cons continuer args)))
           (continuer (fun.apply nil (list-array (cons continuer args))))))))

(defun apply (&rest lst)
  (with (fun lst.
         l (last .lst)
         args (%nconc (butlast .lst) l.))
    (when-debug
      (| (function? fun)
	     (error "First argument ~A is not a function." fun))
	  (| (list? l)
	     (error "Last argument is not a list.")))
    (!? fun.tre-exp
        (!.apply nil (%%native "[" args "]"))
     (fun.apply nil (list-array args)))))

(defun cps-wrap  (x) x)
(defun cps-return-dummy (&rest x))

(defun funcall (fun &rest args)
  (apply fun args))
