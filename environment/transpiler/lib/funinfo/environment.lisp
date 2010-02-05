;;;;; TRE compiler
;;;;; Copyright (C) 2006-2007,2009-2010 Sven Klose <pixel@copei.de>

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

(defun funinfo-in-env? (fi x)
  (href (funinfo-env-hash fi) x))

(defun funinfo-in-args-or-env? (fi x)
  (or (funinfo-arg? fi x)
	  (funinfo-in-env? fi x)))

(defun funinfo-in-parent-env? (fi var)
  (when fi
    (awhen (funinfo-parent fi)
      (or (funinfo-in-args-or-env? ! var)
		  (funinfo-in-parent-env? ! var)))))

(defun funinfo-in-this-or-parent-env? (fi var)
  (when fi
    (or (funinfo-in-args-or-env? fi var)
	    (awhen (funinfo-parent fi)
		  (funinfo-in-this-or-parent-env? ! var)))))

(defun funinfo-in-this-or-parent-env-but-not-toplevel? (fi var)
  (when (and fi
			 (funinfo-parent fi))
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

(defun funinfo-lexical? (fi x)
  (member x (funinfo-lexicals fi)))

(defun funinfo-env-parent (fi)
  (funinfo-env (funinfo-parent fi)))

(defun funinfo-env-add (fi x)
  (unless (funinfo-in-env? fi x)
	; XXX (error "double definition of ~A in ~A" x (funinfo-env fi))
  	(setf (href (funinfo-env-hash fi) x) t)
    (push! x (funinfo-env fi)))
  x)

(defun funinfo-env-add-many (fi x)
  (dolist (i x)
	(funinfo-env-add fi i)))

(defun funinfo-env-reset (fi)
  (setf (funinfo-env fi) nil)
  (setf (funinfo-env-hash fi) (make-hash-table :test #'eq)))

(defun funinfo-add-used-env (fi x)
  (adjoin! x (funinfo-used-env fi) :test #'eq))

(defun funinfo-get-name (fi)
  (when fi
    (or (funinfo-name fi)
		(funinfo-get-name (funinfo-parent fi)))))
