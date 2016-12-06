; tré – Copyright (c) 2008–2010,2013–2016 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate apply call)

,(& (enabled-pass? :cps)
    '{(declare-cps-exception apply methodapply nconc last butlast)
      (declare-native-cps-function apply methodapply)})

(defun apply (fun &rest lst)
  (let l (last lst)
    (assert (function? fun) "First argument ~A is not a function." fun)
    (assert (list? l.) "Last argument is not a list. Got ~A." l)
    (alet (nconc (butlast lst) l.)
      ,(? (enabled-pass? :cps)
          '(?
             (defined? fun.tre-exp)
               (fun.tre-exp.apply nil (%%native "[" ~%cont ", " ! "]"))
             (defined? fun._cps-transformed?)
               (fun.apply nil (list-array (. ~%cont !)))
             (~%cont.call nil (fun.apply nil (list-array !))))
          '(? (defined? fun.tre-exp)
              (fun.tre-exp.apply nil (%%native "[" ! "]"))
              (fun.apply nil (list-array !)))))))

(defun applymethod (obj fun &rest lst)
  ,(? (enabled-pass? :cps)
      '(? (defined? fun._cps-transformed?)
          (fun.apply obj (list-array (. ~%cont lst)))
          (~%cont.call nil (fun.apply obj (list-array lst))))
      '(fun.apply obj (list-array lst))))
