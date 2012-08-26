;;;;; tré – Copyright (c) 2006–2007,2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun funinfo-add-lexical (fi name)
  (adjoin! name (funinfo-lexicals fi)))

(defun funinfo-make-lexical (fi)
  (unless (funinfo-lexical fi)
    (let lexical (gensym)
	  (= (funinfo-lexical fi) lexical)
	  (funinfo-env-add fi lexical))))

(defun funinfo-make-ghost (fi)
  (unless (funinfo-ghost fi)
    (let ghost (gensym)
	  (= (funinfo-ghost fi) ghost)
	  (push ghost (funinfo-args fi))
	  (funinfo-env-add fi ghost))))

(defun funinfo-link-lexically (fi)
  (funinfo-make-lexical (funinfo-parent fi))
  (funinfo-make-ghost fi))

;; XXX link funinfos
(defun funinfo-setup-lexical-links (fi var)
  (let fi-parent (funinfo-parent fi)
    (| fi-parent (error "couldn't find ~A in environment" var))
    (funinfo-add-free-var fi var)
    (funinfo-link-lexically fi)
    (? (funinfo-in-args-or-env? fi-parent var)
	   (funinfo-add-lexical fi-parent var)
       (funinfo-setup-lexical-links fi-parent var))))
