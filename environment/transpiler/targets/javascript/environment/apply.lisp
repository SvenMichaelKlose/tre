;;;;; tré – Copyright (c) 2008–2010,2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate apply call)

,(& (transpiler-cps-transformation? *transpiler*)
    '(progn
       (declare-cps-exception apply methodapply %nconc last butlast)
       (declare-native-cps-function apply methodapply)))

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
           (~%cont.call nil (fun.apply nil (list-array !))))
        '(? (defined? fun.tre-exp)
            (fun.tre-exp.apply nil (%%native "[" ! "]"))
            (fun.apply nil (list-array !))))))

(defun methodapply (obj fun &rest lst)
  ,(? (transpiler-cps-transformation? *transpiler*)
      '(? (defined? fun._cps-transformed?)
          (fun.apply obj (list-array (. ~%cont lst)))
          (~%cont.call nil (fun.apply obj (list-array lst)))))
      '(fun.apply obj (list-array lst)))
