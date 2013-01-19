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

(defun funinfo-var? (fi x)
  (& x (atom x)
     (? (funinfo-parent fi)
        (member x (funinfo-vars fi) :test #'eq)
        (!? (funinfo-vars-hash fi)
            (href ! x)))
     fi))

(defun funinfo-arg-or-var? (fi x)
  (| (funinfo-arg? fi x)
     (funinfo-var? fi x)))

(defun funinfo-parent-var? (fi x)
  (!? (funinfo-parent fi)
      (| (funinfo-arg-or-var? ! x)
	     (funinfo-parent-var? ! x))))

(defun funinfo-var-or-lexical? (fi x)
  (| (funinfo-arg-or-var? fi x)
     (!? (funinfo-parent fi)
         (funinfo-var-or-lexical? ! x))))

(defun funinfo-toplevel-var? (fi x)
  (!? (funinfo-parent fi)
      (& (not (funinfo-arg-or-var? fi x))
         (funinfo-toplevel-var? ! x))
      (funinfo-arg-or-var? fi x)))


;;;; ENVIRONMENT

(defun funinfo-var-pos (fi x)
  (& (funinfo-parent fi)
     (position x (funinfo-vars fi) :test #'eq)))

,`(progn
    ,@(mapcar (fn `(defun ,($ 'funinfo- _.) (fi var)
			   	     (position var (,($ 'funinfo- ._.) fi) :test #'eq)))
		      `((free-var-pos free-vars)
                (lexical-pos lexicals))))

(defun funinfosym-var-pos (fi-sym x)
  (funinfo-var-pos (get-funinfo-by-sym fi-sym) x))

(defun funinfosym-lexical-pos (fi-sym x)
  (funinfo-lexical-pos (get-funinfo-by-sym fi-sym) x))

(defun funinfo-lexical? (fi x)
  (member x (funinfo-lexicals fi) :test #'eq))

(defun funinfo-var-add (fi x)
  (unless (atom x)
	(print x)
	(error "atom expected"))
  (unless (funinfo-var? fi x)
    (? (funinfo-parent fi)
       (append! (funinfo-vars fi) (list x))
       (push x (funinfo-vars fi)))
    (unless (funinfo-parent fi)
	  (= (href (| (funinfo-vars-hash fi)
  	              (= (funinfo-vars-hash fi) (make-hash-table :test #'eq)))
               x)
         t)))
  x)

(defun funinfo-var-add-many (fi x)
  (dolist (i x)
	(funinfo-var-add fi i)))

(defun funinfo-vars-reset (fi)
  (= (funinfo-vars fi) nil)
  (unless (funinfo-parent fi)
    (= (funinfo-vars-hash fi) (make-hash-table :test #'eq))))

(defun funinfo-vars-set (fi x)
  (funinfo-vars-reset fi)
  (funinfo-var-add-many fi x))

(defun funinfo-vars-adjoin (fi x)
  (unless (funinfo-var? fi x)
    (funinfo-var-add fi x)))

(defun funinfo-used-var? (fi x)
  (member x (funinfo-used-vars fi) :test #'eq))

(defun funinfo-add-used-var (fi x)
  (& (funinfo-parent fi)
     (not (funinfo-used-var? fi x))
     (+! (funinfo-used-vars fi) (list x))))

(defun funinfo-get-name (fi)
  (| (funinfo-name fi)
     (funinfo-get-name (funinfo-parent fi))))

(defun funinfo-immutable? (fi x)
  (member x (funinfo-immutables fi) :test #'eq))

(defun funinfo-add-immutable (fi x)
  (adjoin! x (funinfo-immutables fi) :test #'eq))

(defun funinfo-global-variable? (fi x)
  (& (not (funinfo-var-or-lexical? fi x))
     (| (transpiler-defined-variable *current-transpiler* x)
        (transpiler-host-variable? *current-transpiler* x))))
