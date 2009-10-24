;;;;; TRE compiler
;;;;; Copyright (C) 2006-2007,2009 Sven Klose <pixel@copei.de>

;;;; ARGUMENTS

(defun funinfo-arg? (fi var)
  (member var (funinfo-args fi)))

;;;; FREE VARIABLES

(defun funinfo-free-var? (fi var)
  (member var (funinfo-free-vars fi)))

(defun funinfo-add-free-var (fi var)
  (unless (funinfo-free-var? fi var)
    (nconc! (funinfo-free-vars fi) (list var)))
  var)

;;;; ARGUMENTS & ENVIRONMENT

(defun funinfo-in-args-or-env? (fi x)
  (or (funinfo-arg? fi x)
	  (funinfo-env-pos fi x)))

(defun funinfo-in-this-or-parent-env? (fi var)
  (when fi
    (or (funinfo-in-args-or-env? fi var)
	    (awhen (funinfo-parent fi)
		  (funinfo-in-this-or-parent-env? ! var)))))

(defun funinfo-ignore? (fi var)
  (member var (funinfo-ignorance fi)))

;;;; ENVIRONMENT

(defmacro with-funinfo-env-temporary (fi args &rest body)
  (with-gensym old-env
    `(let ,old-env (copy-tree (funinfo-env ,fi))
       (funinfo-env-add-args ,fi ,args)
       (prog1
         (progn
           ,@body)
	     (setf (funinfo-env ,fi) ,old-env)))))

,(macroexpand
	`(progn
	  ,@(mapcar (fn `(defun ,($ 'funinfo- _.) (fi var)
				   	    (position var (,($ 'funinfo- ._.) fi))))
		    (group `(free-var-pos free-vars
					 env-pos env
					 lexical-pos lexicals)
				   2))))

(defun funinfo-env-parent (fi)
  (funinfo-env (funinfo-parent fi)))

(defun funinfo-env-add (fi arg)
  (unless (funinfo-env-pos fi arg)
	  ;(error "double definition of ~A in ~A" arg (funinfo-env fi))
      (append! (funinfo-env fi) (list arg))))

(defun funinfo-env-add-many (fi arg)
  (dolist (x arg)
	(funinfo-env-add fi x)))

(defun funinfo-make-stackplace (fi x)
  (funinfo-env-add fi x)
  `(%stack ,(funinfo-sym fi) ,x))

(defun funinfo-env-all (fi)
  (append (funinfo-env fi)
		  (awhen (funinfo-parent fi)
			(funinfo-env-all !))))

(defun funinfo-add-used-env (fi x)
  (adjoin! x (funinfo-used-env fi) :test #'eq))
