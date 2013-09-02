;;;;; tré – Copyright (c) 2008–2010,2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate apply call)

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

(defun funcall (fun &rest args)
  (apply fun args))
