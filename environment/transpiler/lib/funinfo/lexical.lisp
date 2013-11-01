;;;;; tré – Copyright (c) 2006–2007,2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun funinfo-make-scope (fi)
  (unless (funinfo-scope fi)
    (with-gensym scope
	  (= (funinfo-scope fi) scope)
	  (funinfo-var-add fi scope))))

(defun funinfo-make-ghost (fi)
  (unless (funinfo-ghost fi)
    (with-gensym ghost
	  (= (funinfo-ghost fi) ghost)
	  (push ghost (funinfo-argdef fi))
	  (push ghost (funinfo-args fi)))))

(defun funinfo-link-scope (fi)
  (when (transpiler-lambda-export? *transpiler*)
    (funinfo-make-scope (funinfo-parent fi))
    (funinfo-make-ghost fi)))

(defun funinfo-setup-scope (fi var)
  (alet (funinfo-parent fi)
    (| ! (error "Couldn't find ~A in environment." var))
    (funinfo-link-scope fi)
    (? (funinfo-arg-or-var? ! var)
	   (funinfo-add-scoped-var ! var)
       (funinfo-setup-scope ! var))))
