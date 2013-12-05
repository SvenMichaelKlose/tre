;;;;; tré – Copyright (c) 2008–2010,2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate apply call)
(declare-cps-exception apply %nconc last butlast)

(defun apply (fun &rest lst)
  (when-debug
    (| (function? fun)
	   (error "First argument ~A is not a function." fun))
	(| (list? (car (last lst)))
	   (error "Last argument is not a list.")))
  (alet (%nconc (butlast lst) (car (last lst)))
    ,(? (transpiler-cps-transformation? *transpiler*)
        '(?
           (defined? fun.tre-exp)            (fun.tre-exp.apply nil (%%native "[" ~%cont ", " ! "]"))
           (defined? fun._cps-transformed?)  (fun.apply nil (list-array (. ~%cont !)))
           (~%cont.apply nil (fun.apply nil (list-array !))))
        '(? (defined? fun.tre-exp)
            (fun.tre-exp.apply nil (%%native "[" ! "]"))
            (fun.apply nil (list-array !))))))
