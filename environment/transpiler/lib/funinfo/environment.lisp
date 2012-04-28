;;;;; tré - Copyright (C) 2006-2007,2009-2012 Sven Michael Klose <pixel@copei.de>

;;;; ARGUMENTS

(defun funinfo-arg? (fi var)
  (and (member var (funinfo-args fi) :test #'eq)
       fi))

;;;; FREE VARIABLES

(defun funinfo-free-var? (fi var)
  (member var (funinfo-free-vars fi) :test #'eq))

(defun funinfo-add-free-var (fi var)
  (adjoin! var (funinfo-free-vars fi) :test #'eq)
  var)

;;;; ARGUMENTS & ENVIRONMENT

(defun funinfo-local-args (fi)
  (remove-if (fn funinfo-lexical? fi _)
			 (funinfo-args fi)))

(defun funinfo-in-env? (fi x)
  (when (? (funinfo-parent fi)
           (member x (funinfo-env fi) :test #'eq)
           (href (funinfo-env-hash fi) x))
    fi))

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

(defun funinfo-in-env-or-lexical? (fi var)
  (when (and fi (funinfo-parent fi))
    (or (funinfo-in-args-or-env? fi var)
	    (awhen (funinfo-parent fi)
		  (funinfo-in-env-or-lexical? ! var)))))

(defun funinfo-in-toplevel-env? (fi var)
  (when fi
    (unless (and (funinfo-parent fi)
                 (funinfo-in-args-or-env? fi var))
      (aif (funinfo-parent fi)
		   (funinfo-in-toplevel-env? ! var)
           (funinfo-in-args-or-env? fi var)))))

;;;; ENVIRONMENT

(defmacro with-funinfo-env-temporary (fi args &rest body)
  (with-gensym old-env
    `(let ,old-env (copy-tree (funinfo-env ,fi))
       (funinfo-env-add-args ,fi ,args)
       (prog1
         (progn
           ,@body)
	     (setf (funinfo-env ,fi) ,old-env)))))

,`(progn
    ,@(mapcar (fn `(defun ,($ 'funinfo- _.) (fi var)
			   	     (position var (,($ 'funinfo- ._.) fi) :test #'eq)))
		      `((free-var-pos free-vars)
                (env-pos env)
                (lexical-pos lexicals))))

(defun funinfosym-env-pos (fi-sym x)
  (funinfo-env-pos (get-funinfo-by-sym fi-sym) x))

(defun funinfosym-lexical-pos (fi-sym x)
  (funinfo-lexical-pos (get-funinfo-by-sym fi-sym) x))

(defun funinfo-lexical? (fi x)
  (member x (funinfo-lexicals fi) :test #'eq))

(defun funinfo-env-parent (fi)
  (funinfo-env (funinfo-parent fi)))

(defun funinfo-env-add (fi x)
  (unless (atom x)
	(print x)
	(error "atom expected"))
  (unless (funinfo-in-env? fi x)
	; XXX (error "double definition of ~A in ~A" x (funinfo-env fi))
    (unless (funinfo-parent fi)
  	  (unless (funinfo-env-hash fi)
  	    (setf (funinfo-env-hash fi) (make-hash-table :size 65521 :test #'eq)))
  	  (setf (href (funinfo-env-hash fi) x) t))
    (push x (funinfo-env fi)))
  x)

(defun funinfo-env-add-many (fi x)
  (dolist (i x)
	(funinfo-env-add fi i)))

(defun funinfo-env-reset (fi)
  (setf (funinfo-env fi) nil)
  (unless (funinfo-parent fi)
    (setf (funinfo-env-hash fi) (make-hash-table :test #'eq))))

(defun funinfo-env-set (fi x)
  (? (funinfo-parent fi)
     (setf (funinfo-env fi) x)
     (progn
       (error "no parent")
       (funinfo-env-reset fi)
       (funinfo-env-add-many fi x))))

(defun funinfo-env-adjoin (fi x)
  (unless (funinfo-in-env? fi x)
    (funinfo-env-add fi x)))

(defun funinfo-add-used-env (fi x)
  (adjoin! x (funinfo-used-env fi) :test #'eq))

(defun funinfo-get-name (fi)
  (when fi
    (or (funinfo-name fi)
		(funinfo-get-name (funinfo-parent fi)))))

(defun funinfo-immutable? (fi x)
  (member x (funinfo-immutables fi) :test #'eq))

(defun funinfo-add-immutable (fi x)
  (adjoin! x (funinfo-immutables fi) :test #'eq))
