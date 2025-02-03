(fn funinfo-find (fi x)
  "Find non-global FUNINFO containg arg or var X."
  (!? (funinfo-parent fi)
      (| (funinfo-arg-or-var? fi x)
         (funinfo-find ! x))))


;;;; FUNCTION NAME

(fn funinfo-names (fi)
  "List of FUNFINFO's and its parents names."
  (when fi
    (. (funinfo-name fi)
       (funinfo-names (funinfo-parent fi)))))


;;;; ARGUMENTS

(fn funinfo-arg? (fi x)
  "Test if X is an argument."
  (member x (funinfo-args fi) :test #'eq))

(fn funinfo-arg-pos (fi x)
  "Posiiton of X in argument list."
  (position x (funinfo-args fi) :test #'eq))


;;;; VARIABLES

(fn funinfo-var? (fi x)
  "Test if X is a local variable."
  (& x
     (symbol? x)
     (!? (funinfo-vars-hash fi)
         (href ! x)
         (member x (funinfo-vars fi) :test #'eq))))

(fn funinfo-var-pos (fi x)
  "Posiiton of X in list of local variables."
  (& (funinfo-parent fi)
     (position x (funinfo-vars fi) :test #'eq)))

(fn funinfo-add-var (fi x)
  "Add local variable(s).  Ignored if already added."
  (@ (v (ensure-list x))
    (unless (funinfo-var? fi v)
      (? (funinfo-parent fi)
         (+! (funinfo-vars fi) (… v))
         (push x (funinfo-vars fi)))
      (unless (funinfo-parent fi)
        (= (href (| (funinfo-vars-hash fi)
                    (= (funinfo-vars-hash fi) (make-hash-table :test #'eq)))
                 v)
           t))))
  x)

(fn funinfo-set-vars (fi x)
  "Replace list of local variables."
  (= (funinfo-vars fi) nil)
  (unless (funinfo-parent fi)
    (= (funinfo-vars-hash fi) (make-hash-table :test #'eq)))
  (funinfo-add-var fi x))


;;;; ARGUMENTS & VARIABLES

(fn funinfo-arg-or-var? (fi x)
  "Test if X is an argument or local variable."
  (| (funinfo-arg? fi x)
     (funinfo-var? fi x)))


;;;; LEXICALS

(fn funinfo-scoped-var-index (fi x)
  (position x (funinfo-scoped-vars fi) :test #'eq))

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
  (funinfo-add-var fi x)
  (adjoin! x (funinfo-globals fi)))

(fn funinfo-global-var? (fi x)
  (& (not (funinfo-find fi x))
     (| (defined-variable x)
        (host-variable? x))))
