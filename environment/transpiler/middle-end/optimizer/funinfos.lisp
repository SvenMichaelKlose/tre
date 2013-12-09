;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun used-vars ()
  (alet *funinfo*
    (+ (funinfo-scoped-vars !)
       (intersect (funinfo-vars !) (funinfo-used-vars !) :test #'eq)
       (& (transpiler-copy-arguments-to-stack? *transpiler*)
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
  (when (& (== 1 (length (funinfo-scoped-vars fi)))
           (not (funinfo-place? fi (car (funinfo-scoped-vars fi)))))
    (= (funinfo-scoped-vars fi) nil)
    (= (funinfo-scope fi) nil)
    (optimizer-message "; Removed scoped vars in ~A.~%"
                       (human-readable-funinfo-names fi))))

(defun replace-scope-arg (fi)
  (when (& (funinfo-scope-arg fi)
           (not (funinfo-fast-scope? fi))
           (funinfo-free-vars fi)
           (not (funinfo-scoped-vars (funinfo-parent fi))))
    (| (== 1 (length (funinfo-free-vars fi)))
       (error "Too much free vars."))
    (alet (car (funinfo-free-vars fi))
      (= (funinfo-free-vars fi) nil)
      (= (funinfo-scope-arg fi) !)
      (= (funinfo-argdef fi) (cons ! (cdr (funinfo-argdef fi))))
      (= (funinfo-args fi) (cons ! (cdr (funinfo-args fi))))
      (= (funinfo-fast-scope? fi) t)
      (optimizer-message "; Removed array allocation for single scoped-var in ~A.~%"
                         (human-readable-funinfo-names fi)))))

(defun remove-argument-stackplaces (fi)
  (let v (used-vars)
    (adolist ((funinfo-args fi))
      (| (funinfo-scoped-var? fi !)
         (funinfo-place? fi !)
         (remove! ! v :test #'eq)))
    (funinfo-vars-set fi v)))

(defun warn-unused-arguments (fi)
  (dolist (i (funinfo-args fi))
    (| (funinfo-used-var? fi i)
       (warn "Unused argument ~A of function ~A."
             i (human-readable-funinfo-names fi)))))

(defun correct-funinfo ()
  (alet *funinfo*
    (remove-unused-scope-arg !)
;    (remove-scoped-vars !)
;    (replace-scope-arg !)
;    (warn-unused-arguments !)
    (? (transpiler-stack-locals? *transpiler*)
       (remove-argument-stackplaces !)
       (funinfo-vars-set ! (intersect (funinfo-vars !) (funinfo-used-vars !) :test #'eq)))))

(defun remove-unused-vars (x)
  (& (named-lambda? x.) 
     (with-lambda-funinfo x.
       (correct-funinfo)
       (remove-unused-vars (lambda-body x.))))
  (& x (remove-unused-vars .x)))

(defun optimize-funinfos (x)
  (collect-places x)
  (remove-unused-vars x)
  x)
