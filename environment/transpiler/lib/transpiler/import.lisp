;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defun transpiler-defined? (tr name)
  (or (transpiler-defined-function tr name)
      (transpiler-defined-variable tr name)
      (transpiler-wanted-function? tr name)
  	  (transpiler-wanted-variable? tr name)
	  (transpiler-unwanted-function? tr name)
	  (transpiler-macro tr name)))

(defun transpiler-can-import? (tr name)
  (and (transpiler-import-from-environment? tr)
       (symbol? name)
       (not (builtin? name))
       (not (transpiler-defined? tr name))))
	
(defun transpiler-add-wanted-function (tr x)
  (when (transpiler-can-import? tr x)
    (setf (href (transpiler-wanted-functions-hash tr) x) t)
    (push x (transpiler-wanted-functions tr)))
  x)

(defun transpiler-should-add-wanted-variable? (tr var)
  (and (transpiler-import-from-environment? tr)
       (atom var)
       (symbol? var)
       (not (href (transpiler-wanted-variables-hash tr) var))
	   (assoc var *variables* :test #'eq)))

(defun transpiler-add-wanted-variable (tr var)
  (when (transpiler-should-add-wanted-variable? tr var)
    (setf (href (transpiler-wanted-variables-hash tr) var) t)
    (push var (transpiler-wanted-variables tr)))
  var)

(defun transpiler-import-exported-closures (tr)
  (and (transpiler-exported-closures tr)
	   (append (transpiler-sighten tr (pop (transpiler-exported-closures tr)))
		       (transpiler-import-exported-closures tr))))

(defvar *imported-something* nil)
(defvar *delayed-var-inits* nil)

(defun transpiler-import-wanted-function (tr x)
  (when (eq 'add-to-cart x)
    (print (+ "IMPORTING!")))
  (unless (transpiler-defined-function tr x)
    (let fun (symbol-function x)
      (setf *imported-something* t)
      (transpiler-sighten tr `((defun ,x ,(function-arguments fun)
                                 ,@(function-body fun)))))))

(defun transpiler-import-wanted-functions (tr)
  (with-queue q
    (awhile (pop (transpiler-wanted-functions tr))
            nil
      (enqueue q (transpiler-import-wanted-function tr !)))
    (append (apply #'append (queue-list q))
            (transpiler-import-exported-closures tr))))

(defun transpiler-import-wanted-variables (tr)
  (transpiler-sighten tr
    (mapcar (fn (unless (transpiler-defined-variable tr _)
				  (setf *imported-something* t)
				  (setf *delayed-var-inits* (append (transpiler-sighten tr `((setf ,_ ,(assoc-value _ *variables* :test #'eq))))
 							                        *delayed-var-inits*))
	              `(defvar ,_ nil)))
	        (transpiler-wanted-variables tr))))

(defun transpiler-import-from-environment (tr)
    (print 'IMPORT)
    (print (transpiler-wanted-functions tr))
  (clr *imported-something*)
  (with (funs (transpiler-import-wanted-functions tr)
	     vars (transpiler-import-wanted-variables tr))
    (? *imported-something*
       (append funs vars (transpiler-import-from-environment tr))
       *delayed-var-inits*)))

(defun transpiler-import-from-expex (x)
  (aif (atom-function-expr? x)
       (? (funinfo-in-this-or-parent-env? *expex-funinfo* !)
	      x
          (progn
	        (transpiler-add-wanted-function *current-transpiler* !))
            `(symbol-function (%quote ,!)))
       (or (vec-function-expr? x) x)))

(defun transpiler-import-universe (tr)
  (map (fn transpiler-add-wanted-function tr _) (reverse *defined-functions*)))
