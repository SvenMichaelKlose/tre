;;;;; tré – Copyright (c) 2006–2007,2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun funinfo-scope-arg? (fi x)
  (eq x (funinfo-scope-arg fi)))

(defun funinfo-make-scope (fi)
  (unless (funinfo-scope fi)
    (with-gensym scope
	  (= (funinfo-scope fi) scope)
	  (funinfo-var-add fi scope))))

(defun funinfo-make-scope-arg (fi)
  (unless (funinfo-scope-arg fi)
    (with-gensym scope-arg
	  (= (funinfo-scope-arg fi) scope-arg)
	  (push scope-arg (funinfo-argdef fi))
	  (push scope-arg (funinfo-args fi)))))

(defun funinfo-setup-scope (fi var)
  (alet (funinfo-parent fi)
    (| ! (error "Couldn't find ~A in environment." var))
    (when (transpiler-lambda-export? *transpiler*)
      (funinfo-make-scope (funinfo-parent fi))
      (funinfo-make-scope-arg fi))
    (? (funinfo-arg-or-var? ! var)
	   (funinfo-add-scoped-var ! var)
       (funinfo-setup-scope ! var))))
