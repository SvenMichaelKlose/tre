(fn used-vars ()
  (!= *funinfo*
    (+ (funinfo-scoped-vars !)
       (intersect (funinfo-vars !) (funinfo-used-vars !) :test #'eq)
       (& (copy-arguments-to-stack?)
          (funinfo-args !)))))

(fn remove-unused-scope-arg (fi)
  (& (not (funinfo-fast-scope? fi))
     (funinfo-closure-without-free-vars? fi)
     {(= (funinfo-scope-arg fi) nil)
      (pop (funinfo-args fi))
      (pop (funinfo-argdef fi))
      (optimizer-message "Made ~A a regular function.~%" (human-readable-funinfo-names fi))}))

(fn remove-scoped-vars (fi)
  (& (sole? (funinfo-scoped-vars fi))
     (not (funinfo-place? fi (car (funinfo-scoped-vars fi))))
     {(optimizer-message "Unscoping ~A in ~A.~%"
                         (!= (funinfo-scoped-vars fi)
                           (? .! ! !.))
                         (human-readable-funinfo-names fi))
      (= (funinfo-scoped-vars fi) nil
         (funinfo-scope fi) nil)}))

(fn replace-scope-arg (fi)
  (& (funinfo-scope-arg fi)
     (not (funinfo-fast-scope? fi))
     (sole? (funinfo-free-vars fi))
     (not (funinfo-scoped-vars (funinfo-parent fi)))
     (!= (car (funinfo-free-vars fi))
       (optimizer-message "Removing array allocation for sole scoped ~A in ~A.~%"
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
  (@ (i (funinfo-args fi))
    (| (funinfo-used-var? fi i)
       (warn "Unused argument ~A of function ~A." i (human-readable-funinfo-names fi)))))

(fn correct-funinfo ()
  (!= *funinfo*
    (when (lambda-export?)
      (remove-unused-scope-arg !)
      ;(remove-scoped-vars !)   ; TODO: Fix
      (replace-scope-arg !))
    (funinfo-vars-set ! (intersect (funinfo-vars !) (funinfo-used-vars !) :test #'eq))
    (& (stack-locals?)
       (remove-argument-stackplaces !))))

(fn remove-unused-vars (x)
  (when x
    (& (named-lambda? x.)
       (with-lambda-funinfo x.
         (correct-funinfo)
         (remove-unused-vars (lambda-body x.))))
;         (warn-unused-arguments *funinfo*) ; TODO: Fix.
    (remove-unused-vars .x)))

(fn optimize-funinfos (x)
  (collect-places x)
  (remove-unused-vars x)
  x)
