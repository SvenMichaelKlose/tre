;;;;; tré – Copyright (c) 2008–2010,2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate apply call)
(declare-cps-exception apply %nconc last butlast list-array)

,(? (transpiler-cps-transformation? *transpiler*)
    '(defun apply (fun &rest lst)
       (alet (%nconc (. ~%cont (butlast lst)) (car (last lst)))
         (?
           (defined? fun.tre-exp)            (fun.tre-exp.apply nil (%%native "[" ! "]"))
           (defined? fun._cps-transformed?)  (fun.apply nil (%%native "[" ! "]"))
           (~%cont.apply nil (fun.apply nil (list-array .!))))))
    '(defun apply (fun &rest lst)
       (alet (%nconc (butlast lst) (car (last lst)))
         (when-debug
           (| (function? fun)
	          (error "First argument ~A is not a function." fun))
	       (| (list? (car (last lst)))
	          (error "Last argument is not a list.")))
         (? (defined? fun.tre-exp)
            (fun.tre-exp.apply nil (%%native "[" ! "]"))
            (fun.apply nil (list-array !))))))
