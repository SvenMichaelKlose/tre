(fn funinfo-find (fi x)
  (!? (funinfo-parent fi)
      (| (funinfo-arg-or-var? fi x)
         (funinfo-find ! x))))


;;;; FUNCTION NAME

(fn funinfo-names (fi)
  (& fi
     (. (funinfo-name fi)
        (funinfo-names (funinfo-parent fi)))))


;;;; ARGUMENTS

(fn funinfo-arg? (fi x)
  (& (symbol? x)
     (member x (funinfo-args fi) :test #'eq)
     fi))

(fn funinfo-arg-pos (fi x)
  (position x (funinfo-args fi) :test #'eq))

(fn funinfo-local-args (fi)
  (remove-if [funinfo-scoped-var? fi _] (funinfo-args fi)))


;;;; ARGUMENTS & VARIABLES

(fn funinfo-arg-or-var? (fi x)
  (| (funinfo-arg? fi x)
     (funinfo-var? fi x)))


;;;; VARIABLES

(fn funinfo-var? (fi x)
  (& x (symbol? x)
     (!? (funinfo-vars-hash fi)
         (href ! x)
         (member x (funinfo-vars fi) :test #'eq))
     fi))

(fn funinfo-parent-var? (fi x)
  (!? (funinfo-parent fi)
      (| (funinfo-arg-or-var? ! x)
         (funinfo-parent-var? ! x))))

(fn funinfo-var-pos (fi x)
  (& (funinfo-parent fi)
     (position x (funinfo-vars fi) :test #'eq)))

(fn funinfoname-var-pos (name x)
  (funinfo-var-pos (get-funinfo name) x))

(fn funinfo-var-add (fi x)
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

(fn funinfo-vars-reset (fi)
  (= (funinfo-vars fi) nil)
  (unless (funinfo-parent fi)
    (= (funinfo-vars-hash fi) (make-hash-table :test #'eq))))

(fn funinfo-vars-set (fi x)
  (funinfo-vars-reset fi)
  (@ [funinfo-var-add fi _] x))


;;;; LEXICALS

(fn funinfo-scoped-var-index (fi x)
  (position x (funinfo-scoped-vars fi) :test #'eq))

(fn funinfoname-scoped-var-index (name x)
  (funinfo-scoped-var-index (get-funinfo name) x))

(fn funinfo-add-scoped-var (fi name)
  (adjoin! name (funinfo-scoped-vars fi)))

(fn funinfo-scoped-var? (fi x)
  (member x (funinfo-scoped-vars fi) :test #'eq))


;;;; USED VARIABLES

(fn funinfo-used-var? (fi x)
  (? (funinfo-parent fi)
     (member x (funinfo-used-vars fi) :test #'eq)
     t))

(fn funinfo-add-used-var-0 (fi x)
  (& (funinfo-parent fi)
     (not (funinfo-used-var? fi x))
     (progn
       (push x (funinfo-used-vars fi))
       (| (funinfo-arg-or-var? fi x)
          (!= (funinfo-scope-arg fi)
            (& (not (funinfo-used-var? fi 1))
               (push ! (funinfo-used-vars fi)))
            (funinfo-add-used-var-0 (funinfo-parent fi) x))))))

(fn funinfo-add-used-var (fi x)
  (& (symbol? x)
     (funinfo-find fi x)
     (funinfo-add-used-var-0 fi x)))


;;;; FREE VARIABLES

(fn funinfo-free-var? (fi x)
  (member x (funinfo-free-vars fi) :test #'eq))

(fn funinfo-add-free-var (fi x)
  (| (funinfo-free-var? fi x)
     (push x (funinfo-free-vars fi))))


;;;; PLACES

(fn funinfo-place? (fi x)
  (member x (funinfo-places fi) :test #'eq))

(fn funinfo-add-place (fi x)
  (& x
     (symbol? x)
     (unless (funinfo-place? fi x)
       (push x (funinfo-places fi))
       (| (funinfo-arg-or-var? fi x)
          (!? (funinfo-parent fi)
              (funinfo-add-place ! x))))))


;;;; GLOBAL VARIABLES

(fn funinfo-add-global (fi x)
  (funinfo-var-add fi x)
  (adjoin! x (funinfo-globals fi)))

(fn funinfo-toplevel-var? (fi x)
  (!? (funinfo-parent fi)
      (& (not (funinfo-arg-or-var? fi x))
         (funinfo-toplevel-var? ! x))
      (funinfo-var? fi x)))

(fn funinfo-global-variable? (fi x)
  (& (not (funinfo-find fi x))
     (| (defined-variable x)
        (host-variable? x))))
