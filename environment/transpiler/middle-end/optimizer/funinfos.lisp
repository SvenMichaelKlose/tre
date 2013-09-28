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
    (= (funinfo-places !) (intersect (funinfo-places !) (funinfo-used-vars !)))
    (+ (funinfo-lexicals !)
       (intersect (funinfo-vars !) (funinfo-used-vars !) :test #'eq)
       (& (transpiler-copy-arguments-to-stack? *transpiler*)
          (funinfo-args !)))))

(defun correct-funinfo ()
  (funinfo-vars-set *funinfo* (move-~%ret-to-front (used-vars))))

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
