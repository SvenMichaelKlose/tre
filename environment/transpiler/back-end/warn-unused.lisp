(defun warn-on-unused-variables (fi)
  (when (funinfo-parent fi)
    (adolist ((funinfo-vars fi))
      (| (funinfo-used-var? fi !)
         (warn "Unused symbol ~A in ~A.~%"
               (symbol-name !)
               (human-readable-funinfo-names fi)
               (!? (butlast (funinfo-names fi))
                   (apply #'+ "scope of " (symbol-names-string (reverse !)))
                   "toplevel"))))))

(metacode-walker warn-unused (x)
  :if-named-function {(warn-on-unused-variables (get-lambda-funinfo x.))
                      (warn-unused (lambda-body x.))})
