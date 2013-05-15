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
     (function? (symbol-function name))
     (not (builtin? (symbol-function name)))
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
    (format t "Importing ~A.~%" (symbol-name var))
    (= (href (transpiler-wanted-variables-hash tr) var) t)
    (push var (transpiler-wanted-variables tr)))
  var)

(defun transpiler-import-exported-closures (tr)
  (& (transpiler-exported-closures tr)
     (+ (transpiler-frontend tr (pop (transpiler-exported-closures tr)))
        (transpiler-import-exported-closures tr))))

(defun transpiler-import-wanted-function (tr x)
  (transpiler-frontend tr `((defun ,x ,(transpiler-host-function-arguments tr x)
                              ,@(function-body (symbol-function x))))))

(defun transpiler-import-wanted-functions (tr)
  (with-queue q
    (awhile (pop (transpiler-wanted-functions tr))
            (apply #'+ (queue-list q))
      (unless (transpiler-defined-function tr !)
        (enqueue q (transpiler-import-wanted-function tr !))))))

(defun transpiler-import-wanted-variables (tr)
  (transpiler-frontend tr
      (mapcan [unless (transpiler-defined-variable tr _)
				(transpiler-add-delayed-var-init tr `((= ,_ ,(assoc-value _ *variables* :test #'eq))))
	            `((defvar ,_ nil))]
	          (transpiler-wanted-variables tr))))

(defun transpiler-import-from-environment (tr)
  (with (funs     (transpiler-import-wanted-functions tr)
         exported (transpiler-import-exported-closures tr)
         vars     (transpiler-import-wanted-variables tr))
    (? (| funs exported vars)
       (+ funs exported vars (transpiler-import-from-environment tr))
       (transpiler-delayed-var-inits tr))))

(defun transpiler-import-from-expex (x)
  (? (& (literal-symbol-function? x)
        (not (funinfo-var-or-lexical? *expex-funinfo* .x.)))
     (progn
       (transpiler-add-wanted-function *transpiler* .x.)
       (transpiler-macroexpand *transpiler* `(symbol-function (%quote ,.x.))))
     x))
