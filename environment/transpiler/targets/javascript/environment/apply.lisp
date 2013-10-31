;;;;; tré – Copyright (c) 2008–2010,2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate apply call)

,(? (transpiler-cps-transformation? *transpiler*)
    '(defun apply (&rest lst)
       (with (fun   lst.
              l     (last .lst)
              args  (%nconc (butlast .lst) l.))
         (?
           (defined? fun.tre-exp)  (fun.tre-exp.apply nil (%%native "[" args "]"))
           (defined? fun.tre-cps)  (fun.apply nil (%%native "[" args "]"))
           (let continuer args.
             (continuer.apply nil (fun.apply nil (list-array .args)))))))
    '(defun apply (&rest lst)
       (with (fun   lst.
              l     (last .lst)
              args  (%nconc (butlast .lst) l.))
         (when-debug
           (| (function? fun)
	          (error "First argument ~A is not a function." fun))
	       (| (list? l)
	          (error "Last argument is not a list.")))
         (? (defined? fun.tre-exp)
            (fun.tre-exp.apply nil (%%native "[" args "]"))
            (fun.apply nil (list-array args))))))
