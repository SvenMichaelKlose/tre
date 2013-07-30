;;;;; tré – Copyright (c) 2006–2007,2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun funinfo-add-lexical (fi name)
  (adjoin! name (funinfo-lexicals fi)))

(defun funinfo-make-lexical (fi)
  (unless (funinfo-lexical fi)
    (with-gensym lexical
	  (= (funinfo-lexical fi) lexical)
	  (funinfo-var-add fi lexical))))

(defun funinfo-make-ghost (fi)
  (unless (funinfo-ghost fi)
    (with-gensym ghost
	  (= (funinfo-ghost fi) ghost)
	  (push ghost (funinfo-argdef fi))
	  (push ghost (funinfo-args fi))
	  (funinfo-var-add fi ghost))))

(defun funinfo-link-lexically (fi)
  (funinfo-make-lexical (funinfo-parent fi))
  (funinfo-make-ghost fi))

(defun funinfo-setup-lexical-links (fi var)
  (let fi-parent (funinfo-parent fi)
    (| fi-parent (error "Couldn't find ~A in environment." var))
    (funinfo-add-free-var fi var)
    (funinfo-link-lexically fi)
    (? (funinfo-arg-or-var? fi-parent var)
	   (funinfo-add-lexical fi-parent var)
       (funinfo-setup-lexical-links fi-parent var))))
