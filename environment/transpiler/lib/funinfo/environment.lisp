;;;;; tré – Copyright (c) 2006–2007,2009–2013 Sven Michael Klose <pixel@copei.de>


;;;; FUNCTION NAME

(defun funinfo-names (fi)
  (& fi (cons (funinfo-name fi) (funinfo-names (funinfo-parent fi)))))

;;;; ARGUMENTS

(defun funinfo-arg? (fi var)
  (& (symbol? var)
     (member var (funinfo-args fi) :test #'eq)))

(defun funinfo-arg-pos (fi x)
  (position x (funinfo-args fi) :test #'eq))

(defun funinfo-local-args (fi)
  (remove-if [funinfo-lexical? fi _] (funinfo-args fi)))


;;;; ARGUMENTS & VARIABLES

(defun funinfo-var? (fi x)
  (& x
     (symbol? x)
     (!? (funinfo-vars-hash fi)
         (href ! x)
         (member x (funinfo-vars fi) :test #'eq))))

(defun funinfo-arg-or-var? (fi x)
  (| (funinfo-arg? fi x)
     (funinfo-var? fi x)))

(defun funinfo-var-or-lexical? (fi x)
  (!? (funinfo-parent fi)
      (| (funinfo-arg-or-var? fi x)
         (funinfo-var-or-lexical? ! x))))


;;;; ENVIRONMENT

(defun funinfo-parent-var? (fi x)
  (!? (funinfo-parent fi)
      (| (funinfo-arg-or-var? ! x)
         (funinfo-parent-var? ! x))))

(defun funinfo-var-pos (fi x)
  (& (funinfo-parent fi)
     (position x (funinfo-vars fi) :test #'eq)))

(defun funinfosym-var-pos (name x)
  (funinfo-var-pos (get-funinfo name) x))

(defun funinfo-var-add (fi x)
  (unless (atom x)
	(print x)
	(error "Atom expected."))
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


;;;; LEXICAL CONTEXT

(defun funinfo-lexical-pos (fi x)
  (position x (funinfo-lexicals fi) :test #'eq))

(defun funinfosym-lexical-pos (name x)
  (funinfo-lexical-pos (get-funinfo name) x))

(defun funinfo-lexical? (fi x)
  (member x (funinfo-lexicals fi) :test #'eq))


;;;; USED VARIABLES

(defun funinfo-used-var? (fi x)
  (? (funinfo-parent fi)
     (member x (funinfo-used-vars fi) :test #'eq)
     t))

(defun funinfo-add-used-var (fi x)
  (& (symbol? x)
     (funinfo-parent fi)
     (not (funinfo-used-var? fi x))
     (progn
       (push x (funinfo-used-vars fi))
       (| (funinfo-arg-or-var? fi x)
          (funinfo-add-used-var (funinfo-parent fi) x)))))


;;;; FREE VARIABLES

(defun funinfo-add-free-var (fi x)
  (| (member x (funinfo-free-vars fi) :test #'eq)
     (push x (funinfo-free-vars fi))))


;;;; PLACES

(defun funinfo-place? (fi x)
  (member x (funinfo-places fi) :test #'eq))

(defun funinfo-add-place (fi x)
  (& x
     (symbol? x)
     (unless (funinfo-place? fi x)
        (push x (funinfo-places fi))
        (| (funinfo-arg-or-var? fi x)
           (!? (funinfo-parent fi)
               (funinfo-add-place ! x))))))


;;;; GLOBAL VARIABLES

(defun funinfo-toplevel-var? (fi x)
  (!? (funinfo-parent fi)
      (& (not (funinfo-arg-or-var? fi x))
         (funinfo-toplevel-var? ! x))
      (funinfo-var? fi x)))

(defun funinfo-global-variable? (fi x)
  (& (not (funinfo-var-or-lexical? fi x))
     (| (transpiler-defined-variable *transpiler* x)
        (transpiler-host-variable? *transpiler* x))))
