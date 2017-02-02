(defun funinfo-find (fi x)
  (!? (funinfo-parent fi)
      (| (funinfo-arg-or-var? fi x)
         (funinfo-find ! x))))


;;;; FUNCTION NAME

(defun funinfo-names (fi)
  (& fi (. (funinfo-name fi)
           (funinfo-names (funinfo-parent fi)))))


;;;; ARGUMENTS

(defun funinfo-arg? (fi var)
  (& (symbol? var)
     (member var (funinfo-args fi) :test #'eq)
     fi))

(defun funinfo-arg-pos (fi x)
  (position x (funinfo-args fi) :test #'eq))

(defun funinfo-local-args (fi)
  (remove-if [funinfo-scoped-var? fi _] (funinfo-args fi)))


;;;; ARGUMENTS & VARIABLES

(defun funinfo-arg-or-var? (fi x)
  (| (funinfo-arg? fi x)
     (funinfo-var? fi x)))


;;;; VARIABLES

(defun funinfo-var? (fi x)
  (& x
     (symbol? x)
     (!? (funinfo-vars-hash fi)
         (href ! x)
         (member x (funinfo-vars fi) :test #'eq))
     fi))

(defun funinfo-parent-var? (fi x)
  (!? (funinfo-parent fi)
      (| (funinfo-arg-or-var? ! x)
         (funinfo-parent-var? ! x))))

(defun funinfo-var-pos (fi x)
  (& (funinfo-parent fi)
     (position x (funinfo-vars fi) :test #'eq)))

(defun funinfoname-var-pos (name x)
  (funinfo-var-pos (get-funinfo name) x))

(defun funinfo-var-add (fi x)
  (assert (atom x) (error "Atom expected instead of ~A."))
  (unless (funinfo-var? fi x)
    (? (funinfo-parent fi)
       (+! (funinfo-vars fi) (list x))
       (push x (funinfo-vars fi)))
    (unless (funinfo-parent fi)
	  (= (href (| (funinfo-vars-hash fi)
  	              (= (funinfo-vars-hash fi) (make-hash-table :test #'eq)))
               x)
         t)))
  x)

(defun funinfo-vars-reset (fi)
  (= (funinfo-vars fi) nil)
  (unless (funinfo-parent fi)
    (= (funinfo-vars-hash fi) (make-hash-table :test #'eq))))

(defun funinfo-vars-set (fi x)
  (funinfo-vars-reset fi)
  (@ [funinfo-var-add fi _] x))


;;;; LEXICALS

(defun funinfo-scoped-var-index (fi x)
  (position x (funinfo-scoped-vars fi) :test #'eq))

(defun funinfoname-scoped-var-index (name x)
  (funinfo-scoped-var-index (get-funinfo name) x))

(defun funinfo-add-scoped-var (fi name)
  (adjoin! name (funinfo-scoped-vars fi)))

(defun funinfo-scoped-var? (fi x)
  (member x (funinfo-scoped-vars fi) :test #'eq))


;;;; USED VARIABLES

(defun funinfo-used-var? (fi x)
  (? (funinfo-parent fi)
     (member x (funinfo-used-vars fi) :test #'eq)
     t))

(defun funinfo-add-used-var-0 (fi x)
  (& (funinfo-parent fi)
     (not (funinfo-used-var? fi x))
     {(push x (funinfo-used-vars fi))
      (| (funinfo-arg-or-var? fi x)
         (alet (funinfo-scope-arg fi)
           (& (not (funinfo-used-var? fi 1))
              (push ! (funinfo-used-vars fi)))
           (funinfo-add-used-var-0 (funinfo-parent fi) x)))}))

(defun funinfo-add-used-var (fi x)
  (& (symbol? x)
     (funinfo-find fi x)
     (funinfo-add-used-var-0 fi x)))


;;;; FREE VARIABLES

(defun funinfo-free-var? (fi x)
  (member x (funinfo-free-vars fi) :test #'eq))

(defun funinfo-add-free-var (fi x)
  (| (funinfo-free-var? fi x)
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
  (& (not (funinfo-find fi x))
     (| (defined-variable x)
        (host-variable? x))))
