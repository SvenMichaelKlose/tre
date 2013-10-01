;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun collect-places (x)
  (?
    (named-lambda? x.) (with-lambda-funinfo x.
                         (funinfo-add-used-var *funinfo* (funinfo-lexical *funinfo*))
                         (collect-places (lambda-body x.)))
    (%%go-cond? x.)    (& *funinfo*
                          (funinfo-add-used-var *funinfo* (%%go-value x.)))
    (%setq? x.)        (awhen *funinfo*
                          (funinfo-add-place ! (%setq-place x.))
                          (funinfo-add-used-var ! (%setq-place x.))
                          (? (atom (%setq-value x.))
                             (funinfo-add-used-var ! (%setq-value x.))
                             (dolist (i (%setq-value x.))
                               (funinfo-add-used-var ! i)))))
  (& x (collect-places .x)))

(defun move-~%ret-to-front (x)
  (? (member '~%ret x :test #'eq)
     (cons '~%ret (remove '~%ret x :test #'eq))
     x))

(defun used-vars ()
  (alet *funinfo*
    (+ (funinfo-lexicals !)
       (intersect (funinfo-vars !) (funinfo-used-vars !) :test #'eq)
       (& (transpiler-copy-arguments-to-stack? *transpiler*)
          (funinfo-args !)))))

(defun remove-unused-ghost (fi)
  (when (funinfo-closure-without-free-vars? fi)
     (= (funinfo-ghost fi) nil)
     (pop (funinfo-args fi))
     (pop (funinfo-argdef fi))
     (optimizer-message "; Removed ghost from function ~A.~%" (funinfo-name fi))))

(defun remove-argument-stackplaces (fi)
  (let v (used-vars)
    (adolist ((funinfo-args fi))
      (| (funinfo-lexical? fi !)
         (funinfo-place? fi !)
         (remove! ! v :test #'eq)))
    (funinfo-vars-set fi v)))

(defun warn-unused-arguments (fi)
  (dolist (i (funinfo-args fi))
    (| (funinfo-used-var? fi i)
       (warn "Unused argument ~A of function ~A." i (human-readable-funinfo-names fi)))))

(defun correct-funinfo ()
  (alet *funinfo*
    (remove-unused-ghost !)
;    (warn-unused-arguments !)
    (& (transpiler-stack-locals? *transpiler*)
       (remove-argument-stackplaces !))))

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
