;;;;; TRE compiler
;;;;; Copyright (C) 2006-2007,2009 Sven Klose <pixel@copei.de>

;;;; LEXICALS AND GHOST ARGUMENTS

(defun funinfo-add-lexical (fi name)
  (unless (funinfo-lexical? fi name)
    (nconc! (funinfo-lexicals fi) (list name))))

(defun funinfo-make-lexical (fi)
  (unless (funinfo-lexical fi)
    (let lexical (gensym)
	  (setf (funinfo-lexical fi) lexical)
	  (funinfo-env-add fi lexical))))

(defun funinfo-make-ghost (fi)
  (unless (funinfo-ghost fi)
    (let ghost (gensym)
	  (setf (funinfo-ghost fi) ghost)
	  (setf (funinfo-args fi)
		    (cons ghost
				  (funinfo-args fi)))
	  (funinfo-env-add fi ghost))))

(defun funinfo-link-lexically (fi)
  (funinfo-make-lexical (funinfo-parent fi))
  (funinfo-make-ghost fi))

;; Make lexical path to desired variable.
(defun funinfo-setup-lexical-links (fi var)
  (let fi-parent (funinfo-parent fi)
    (unless fi-parent
	  (error "couldn't find ~A in environment" var))
    (funinfo-add-free-var fi var)
    (funinfo-link-lexically fi)
    (if (funinfo-in-args-or-env? fi-parent var)
	    (funinfo-add-lexical fi-parent var)
        (funinfo-setup-lexical-links fi-parent var))))
