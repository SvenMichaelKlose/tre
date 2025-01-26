(fn collect-places (x)
  (@ [?
       (named-lambda? _)
         (with-lambda-funinfo _
           (let fi *funinfo*
             (!? (funinfo-scope fi)
                 (= (funinfo-used-vars fi) (… !)))
             (= (funinfo-places fi) nil)
             (collect-places (lambda-body _))))
       (conditional-%go? _)
         (funinfo-add-used-var *funinfo* (%go-value _))
       (%=? _)
         (let fi *funinfo*
           (with-%= p v _
             (funinfo-add-place fi p)
             (funinfo-add-used-var fi p)
             (@ [funinfo-add-used-var fi _]
                (ensure-list v))))]
     x)
  x)

(fn used-vars ()
  (!= *funinfo*
    (+ (funinfo-scoped-vars !)
       (intersect (funinfo-vars !) (funinfo-used-vars !))
       (& (copy-arguments-to-stack?)
          (funinfo-args !)))))

(fn remove-unused-scope-arg (fi)
  (& (not (funinfo-fast-scope? fi))
     (funinfo-closure-without-free-vars? fi)
     (progn
       (= (funinfo-scope-arg fi) nil)
       (pop (funinfo-args fi))
       (pop (funinfo-argdef fi))
       (optimizer-message "Made ~A a regular function.~%"
                          (human-readable-funinfo-names fi)))))

(fn remove-scoped-vars (fi)
  (when (& (sole? (funinfo-scoped-vars fi))
           (not (funinfo-place? fi (car (funinfo-scoped-vars fi)))))
    (optimizer-message "Unscoping ~A in ~A.~%"
                       (!= (funinfo-scoped-vars fi)
                         (? .! ! !.))
                       (human-readable-funinfo-names fi))
    (= (funinfo-scoped-vars fi) nil
       (funinfo-scope fi)       nil)))

(fn replace-scope-arg (fi)
  (& (funinfo-scope-arg fi)
     (not (funinfo-fast-scope? fi))
     (sole? (funinfo-free-vars fi))
     (not (funinfo-scoped-vars (funinfo-parent fi)))
     (!= (car (funinfo-free-vars fi))
       (optimizer-message
           "Removing array allocation for sole scoped ~A in ~A.~%"
           ! (human-readable-funinfo-names fi))
       (= (funinfo-free-vars fi)    nil
          (funinfo-scope-arg fi)    !
          (funinfo-argdef fi)       (. ! (cdr (funinfo-argdef fi)))
          (funinfo-args fi)         (. ! (cdr (funinfo-args fi)))
          (funinfo-fast-scope? fi)  t))))

(fn remove-argument-stackplaces (fi)
  (funinfo-vars-set fi (remove-if [& (funinfo-arg? fi _)
                                     (not (funinfo-scoped-var? fi _)
                                          (funinfo-place? fi _))]
                                  (funinfo-vars fi))))

(fn warn-unused-arguments (fi)
  (return) ; TODO: Instead of renamed args show real names.
  (@ (i (funinfo-args fi))
    (| (funinfo-used-var? fi i)
       (warn "Unused argument ~A of function ~A."
             i (human-readable-funinfo-names fi)))))

(fn correct-funinfo (fi)
  (when (lambda-export?)
    (remove-unused-scope-arg fi)
    ;(remove-scoped-vars fi)   ; TODO: Fix
    (replace-scope-arg fi))
  (funinfo-vars-set fi (intersect (funinfo-vars fi) (funinfo-used-vars fi)))
  (& (stack-locals?)
     (remove-argument-stackplaces fi)))

(fn remove-unused-vars (x)
  (when x
    (& (named-lambda? x.)
       (with-lambda-funinfo x.
         (correct-funinfo *funinfo*)
         (remove-unused-vars (lambda-body x.))
         (warn-unused-arguments *funinfo*)))
    (remove-unused-vars .x)))

(fn optimize-funinfos (x)
  (collect-places x)
  (remove-unused-vars x)
  x)
