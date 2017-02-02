(defun used-vars ()
  (alet *funinfo*
    (+ (funinfo-scoped-vars !)
       (intersect (funinfo-vars !) (funinfo-used-vars !) :test #'eq)
       (& (copy-arguments-to-stack?)
          (funinfo-args !)))))

(defun remove-unused-scope-arg (fi)
  (when (& (not (funinfo-fast-scope? fi))
           (funinfo-closure-without-free-vars? fi))
     (= (funinfo-scope-arg fi) nil)
     (pop (funinfo-args fi))
     (pop (funinfo-argdef fi))
     (optimizer-message "; Made ~A a regular function.~%"
                        (human-readable-funinfo-names fi))))

(defun remove-scoped-vars (fi)
  (when (& (sole? (funinfo-scoped-vars fi))
           (not (funinfo-place? fi (car (funinfo-scoped-vars fi)))))
    (optimizer-message "; Unscoping ~A in ~A.~%"
                       (alet (funinfo-scoped-vars fi) (? .! ! !.))
                       (human-readable-funinfo-names fi))
    (= (funinfo-scoped-vars fi) nil)
    (= (funinfo-scope fi) nil)))

(defun replace-scope-arg (fi)
  (when (& (funinfo-scope-arg fi)
           (not (funinfo-fast-scope? fi))
           (sole? (funinfo-free-vars fi))
           (not (funinfo-scoped-vars (funinfo-parent fi))))
    (alet (car (funinfo-free-vars fi))
      (optimizer-message "; Removing array allocation for sole scoped ~A in ~A.~%"
                         ! (human-readable-funinfo-names fi))
      (= (funinfo-free-vars fi) nil)
      (= (funinfo-scope-arg fi) !)
      (= (funinfo-argdef fi) (. ! (cdr (funinfo-argdef fi))))
      (= (funinfo-args fi) (. ! (cdr (funinfo-args fi))))
      (= (funinfo-fast-scope? fi) t))))

(defun remove-argument-stackplaces (fi)
  (funinfo-vars-set fi (remove-if [& (funinfo-arg? fi _)
                                     (not (funinfo-scoped-var? fi _)
                                          (funinfo-place? fi _))]
                                  (funinfo-vars fi))))

(defun warn-unused-arguments (fi)
  (@ (i(funinfo-args fi))
    (| (funinfo-used-var? fi i)
       (warn "Unused argument ~A of function ~A."
             ! (human-readable-funinfo-names fi)))))

(defun correct-funinfo ()
  (alet *funinfo*
;    (when (lambda-export?)
;      (remove-unused-scope-arg !)
;      ;(remove-scoped-vars !)
;      (replace-scope-arg !))
    (funinfo-vars-set ! (intersect (funinfo-vars !) (funinfo-used-vars !) :test #'eq))
    (when (stack-locals?)
      (remove-argument-stackplaces !))))

(defun remove-unused-vars (x)
  (& (named-lambda? x.) 
     (with-lambda-funinfo x.
       (correct-funinfo)
       (remove-unused-vars (lambda-body x.))))
       ;(warn-unused-arguments *funinfo*)))
  (& x (remove-unused-vars .x)))

(defun optimize-funinfos (x)
  (collect-places x)
  (remove-unused-vars x)
  x)
