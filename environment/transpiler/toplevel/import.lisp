;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun transpiler-defined? (tr name)
  (| (transpiler-defined-function tr name)
     (transpiler-defined-variable tr name)
     (transpiler-wanted-function? tr name)
     (transpiler-wanted-variable? tr name)
     (transpiler-unwanted-function? tr name)
     (transpiler-macro tr name)))

(defun transpiler-can-import? (tr name)
  (& (transpiler-import-from-environment? tr)
     (symbol? name)
     (not (builtin? name))
     (not (transpiler-defined? tr name))))
	
(defun transpiler-add-wanted-function (tr x)
  (when (transpiler-can-import? tr x)
    (= (href (transpiler-wanted-functions-hash tr) x) t)
    (push x (transpiler-wanted-functions tr)))
  x)

(defun transpiler-add-wanted-functions (tr x)
  (dolist (i x x)
    (transpiler-add-wanted-function tr i)))

(defun transpiler-must-add-wanted-variable? (tr var)
  (& (transpiler-import-from-environment? tr)
     (atom var)
     (symbol? var)
     (not (href (transpiler-wanted-variables-hash tr) var))
     (| (transpiler-host-variable? tr var)
        (assoc var *constants* :test #'eq))))

(defun transpiler-add-wanted-variable (tr var)
  (when (transpiler-must-add-wanted-variable? tr var)
    (= (href (transpiler-wanted-variables-hash tr) var) t)
    (push var (transpiler-wanted-variables tr)))
  var)

(defun transpiler-import-exported-closures (tr)
  (& (transpiler-exported-closures tr)
     (+ (transpiler-frontend tr (pop (transpiler-exported-closures tr)))
        (transpiler-import-exported-closures tr))))

(defun transpiler-import-wanted-function (tr x)
  (unless (transpiler-defined-function tr x)
    (let fun (symbol-function x)
      (transpiler-frontend tr `((defun ,x ,(transpiler-host-function-arguments tr x)
                                 ,@(function-body fun)))))))

(defun transpiler-import-wanted-functions (tr)
  (with-queue q
    (awhile (pop (transpiler-wanted-functions tr))
            nil
      (awhen (transpiler-import-wanted-function tr !)
        (enqueue q !)))
    (apply #'+ (queue-list q))))

(defun transpiler-import-wanted-variables (tr)
  (transpiler-frontend tr
      (mapcan [unless (transpiler-defined-variable tr _)
				(transpiler-add-delayed-var-init tr `((= ,_ ,(assoc-value _ *variables* :test #'eq))))
	            `((defvar ,_ nil))]
	          (transpiler-wanted-variables tr))))

(defun transpiler-import-from-environment (tr)
  (with (funs (transpiler-import-wanted-functions tr)
         exported (transpiler-import-exported-closures tr)
	     vars (transpiler-import-wanted-variables tr))
    (? (| funs exported vars)
       (+ funs exported vars (transpiler-import-from-environment tr))
       (transpiler-delayed-var-inits tr))))

(defun transpiler-import-from-expex (x)
  (!? (static-symbol-function? x)
      (? (funinfo-in-this-or-parent-env? *expex-funinfo* !)
	     x
         (progn
	       (transpiler-add-wanted-function *current-transpiler* !)
           (transpiler-macroexpand *current-transpiler* `(symbol-function (%quote ,!)))))
      x))
;      (| (vec-function-expr? x) x)))

(defun transpiler-import-universe (tr)
  (map [transpiler-add-wanted-function tr _] (reverse *defined-functions*)))
