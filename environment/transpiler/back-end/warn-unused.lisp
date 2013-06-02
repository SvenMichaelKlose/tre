;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun warn-on-unused-variables (fi)
  (when (funinfo-parent fi)
    (adolist ((funinfo-vars fi))
      (| (funinfo-used-var? fi !)
         (warn "Unused symbol ~A in ~A.~%"
               (symbol-name !)
               (funinfo-scope-description fi)
               (!? (butlast (funinfo-names fi))
                   (apply #'+ "scope of " (pad (symbol-names (reverse !)) " "))
                   "toplevel"))))))

(metacode-walker warn-unused (x)
  :if-named-function (progn
                       (warn-on-unused-variables (get-lambda-funinfo x.))
                       (warn-unused (lambda-body x.))))
