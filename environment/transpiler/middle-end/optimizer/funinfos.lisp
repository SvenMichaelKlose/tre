;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun used-vars ()
  (alet *funinfo*
    (+ (funinfo-lexicals !)
       (intersect (funinfo-vars !) (funinfo-used-vars !) :test #'eq)
       (& (transpiler-copy-arguments-to-stack? *transpiler*)
          (funinfo-args !)))))

(defun remove-unused-ghost (fi)
  (when (& (not (funinfo-fast-lexical? fi))
           (funinfo-closure-without-free-vars? fi))
     (= (funinfo-ghost fi) nil)
     (pop (funinfo-args fi))
     (pop (funinfo-argdef fi))
     (optimizer-message "; Turned closure ~A into regular function.~%" (funinfo-name fi))))

(defun remove-lexicals (fi)
  (when (& (== 1 (length (funinfo-lexicals fi)))
           (not (funinfo-place? fi (car (funinfo-lexicals fi)))))
    (= (funinfo-lexicals fi) nil)
    (= (funinfo-lexical fi) nil)
    (optimizer-message "; Removed lexicals in ~A.~%"
                       (human-readable-funinfo-names fi))))

(defun replace-ghost (fi)
  (when (& (funinfo-ghost fi)
           (not (funinfo-fast-lexical? fi))
           (funinfo-free-vars fi)
           (not (funinfo-lexicals (funinfo-parent fi))))
    (| (== 1 (length (funinfo-free-vars fi)))
       (error "Too much free vars."))
    (alet (car (funinfo-free-vars fi))
      (= (funinfo-free-vars fi) nil)
      (= (funinfo-ghost fi) !)
      (= (funinfo-argdef fi) (cons ! (cdr (funinfo-argdef fi))))
      (= (funinfo-args fi) (cons ! (cdr (funinfo-args fi))))
      (= (funinfo-fast-lexical? fi) t)
      (optimizer-message "; Removed array allocation for single lexical in ~A.~%"
                         (human-readable-funinfo-names fi)))))

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
;    (remove-lexicals !)
;    (replace-ghost !)
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
