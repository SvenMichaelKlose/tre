;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun transpiler-defined? (tr x)
  (| (transpiler-defined-function tr x)
     (transpiler-defined-variable tr x)
     (transpiler-wanted-function? tr x)
     (transpiler-wanted-variable? tr x)
     (transpiler-macro tr x)))

(defun transpiler-can-import? (tr x)
  (& (function? (symbol-function x))
     (not (builtin? (symbol-function x))
          (transpiler-defined? tr x))))
	
(defun transpiler-add-wanted-function (tr x)
  (when (transpiler-can-import? tr x)
    (= (href (transpiler-wanted-functions-hash tr) x) t)
    (push x (transpiler-wanted-functions tr))
    (& *show-definitions?*
       (format t "; Scheduled function ~A for import from environment.~%" x)))
  x)

(defun transpiler-add-wanted-functions (tr x)
  (dolist (i x x)
    (transpiler-add-wanted-function tr i)))

(defun transpiler-must-add-wanted-variable? (tr x)
  (& (atom x)
     (symbol? x)
     (not (href (transpiler-wanted-variables-hash tr) x))
     (| (transpiler-host-variable? tr x)
        (assoc x *constants* :test #'eq))))

(defun transpiler-add-wanted-variable (tr x)
  (when (transpiler-must-add-wanted-variable? tr x)
    (= (href (transpiler-wanted-variables-hash tr) x) t)
    (push x (transpiler-wanted-variables tr))
    (& *show-definitions?*
       (format t "; Scheduled global variable ~A for import from environment.~%" x)))
  x)

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
  (when (transpiler-import-from-environment? tr)
    (with (funs     (transpiler-import-wanted-functions tr)
           exported (transpiler-import-exported-closures tr)
           vars     (transpiler-import-wanted-variables tr))
      (? (| funs exported vars)
         (+ funs exported vars (transpiler-import-from-environment tr))
         (transpiler-delayed-var-inits tr)))))

(defun global-literal-symbol-function? (x)
  (& (literal-symbol-function? x)
     (not (funinfo-var-or-lexical? *funinfo* .x.))))

(defun transpiler-import-add-used (x)
  (unless (member x (funinfo-names *funinfo*) :test #'eq)
    (transpiler-add-used-function *transpiler* x))
  x)

(defun transpiler-import-from-expex (x)
  (? (global-literal-symbol-function? x)
         (progn
           (transpiler-add-wanted-function *transpiler* .x.)
           (transpiler-import-add-used .x.)
           (transpiler-macroexpand *transpiler* `(symbol-function (%quote ,.x.))))
     (cons? x)
         (progn
           (transpiler-import-add-used (? (%%closure? x)
                                          .x.
                                          x.))
           x)
     x))
