; tré – Copyright (c) 2008–2010,2013–2016 Sven Michael Klose <pixel@copei.de>

(defun apply (fun &rest lst)
  (let l (last lst)
    (assert (function? fun) "First argument ~A is not a function." fun)
    (assert (list? l.) "Last argument is not a list. Got ~A." l)
    (alet (nconc (butlast lst) l.)
      (? (defined? fun.tre-exp)
         (fun.tre-exp.apply nil (%%native "[" ! "]"))
         (fun.apply nil (list-array !))))))

(defun applymethod (obj fun &rest lst)
  (fun.apply obj (list-array lst)))
