;;;;; tré – Copyright (c) 2006–2007,2009–2013 Sven Michael Klose <pixel@copei.de>

;;;; ARGUMENTS

(defun funinfo-arg? (fi var)
  (& (member var (funinfo-args fi) :test #'eq)
     fi))

(defun funinfo-arg-pos (fi x)
  (position x (funinfo-args fi) :test #'eq))

;;;; FREE VARIABLES

(defun funinfo-free-var? (fi var)
  (member var (funinfo-free-vars fi) :test #'eq))

(defun funinfo-add-free-var (fi var)
  (adjoin! var (funinfo-free-vars fi) :test #'eq)
  var)

;;;; ARGUMENTS & ENVIRONMENT

(defun funinfo-local-args (fi)
  (remove-if [funinfo-lexical? fi _] (funinfo-args fi)))

(defun funinfo-in-env? (fi x)
  (& x (atom x)
     (? (funinfo-parent fi)
        (member x (funinfo-env fi) :test #'eq)
        (!? (funinfo-env-hash fi)
            (href ! x)))
     fi))

(defun funinfo-in-args-or-env? (fi x)
  (| (funinfo-arg? fi x)
     (funinfo-in-env? fi x)))

(defun funinfo-in-parent-env? (fi x)
  (!? (funinfo-parent fi)
      (| (funinfo-in-args-or-env? ! x)
	     (funinfo-in-parent-env? ! x))))

(defun funinfo-in-env-or-lexical? (fi x)
  (| (funinfo-in-args-or-env? fi x)
     (!? (funinfo-parent fi)
         (funinfo-in-env-or-lexical? ! x))))

(defun funinfo-in-toplevel-env? (fi x)
  (!? (funinfo-parent fi)
      (& (not (funinfo-in-args-or-env? fi x))
         (funinfo-in-toplevel-env? ! x))
      (funinfo-in-args-or-env? fi x)))


;;;; ENVIRONMENT

(defun funinfo-env-pos (fi x)
  (& (funinfo-parent fi)
     (position x (funinfo-env fi) :test #'eq)))

,`(progn
    ,@(mapcar (fn `(defun ,($ 'funinfo- _.) (fi var)
			   	     (position var (,($ 'funinfo- ._.) fi) :test #'eq)))
		      `((free-var-pos free-vars)
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
    (? (funinfo-parent fi)
       (append! (funinfo-env fi) (list x))
       (push x (funinfo-env fi)))
    (unless (funinfo-parent fi)
	  (= (href (| (funinfo-env-hash fi)
  	              (= (funinfo-env-hash fi) (make-hash-table :test #'eq)))
               x)
         t)))
  x)

(defun funinfo-env-add-many (fi x)
  (dolist (i x)
	(funinfo-env-add fi i)))

(defun funinfo-env-reset (fi)
  (= (funinfo-env fi) nil)
  (unless (funinfo-parent fi)
    (= (funinfo-env-hash fi) (make-hash-table :test #'eq))))

(defun funinfo-env-set (fi x)
  (funinfo-env-reset fi)
  (funinfo-env-add-many fi x))

(defun funinfo-env-adjoin (fi x)
  (unless (funinfo-in-env? fi x)
    (funinfo-env-add fi x)))

(defun funinfo-used-env? (fi x)
  (member x (funinfo-used-env fi) :test #'eq))

(defun funinfo-add-used-env (fi x)
  (& (funinfo-parent fi)
     (not (funinfo-used-env? fi x))
     (+! (funinfo-used-env fi) (list x))))

(defun funinfo-get-name (fi)
  (| (funinfo-name fi)
     (funinfo-get-name (funinfo-parent fi))))

(defun funinfo-immutable? (fi x)
  (member x (funinfo-immutables fi) :test #'eq))

(defun funinfo-add-immutable (fi x)
  (adjoin! x (funinfo-immutables fi) :test #'eq))

(defun funinfo-global-variable? (fi x)
  (& (not (funinfo-in-env-or-lexical? fi x))
     (| (transpiler-defined-variable *current-transpiler* x)
        (transpiler-host-variable? *current-transpiler* x))))
