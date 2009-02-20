;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Import functions and variable from the environment.

(defun transpiler-defined? (tr name)
  (or (transpiler-defined-function tr name)
  	  (transpiler-defined-variable tr name)
  	  (transpiler-wanted-function? tr name)
  	  (transpiler-wanted-variable? tr name)
	  (transpiler-unwanted-function? tr name)
	  (transpiler-macro tr name)))

(defun transpiler-can-import? (tr name)
  (and (transpiler-import-from-environment? tr)
  	   (not (transpiler-defined? tr name))))
	
(defun transpiler-add-wanted-function (tr fun)
  (when (transpiler-can-import? tr fun)
	(setf (href fun (transpiler-wanted-functions-hash tr)) t)
	(nconc! (transpiler-wanted-functions tr)
			(list fun))))

(defun transpiler-should-add-wanted-variable? (tr var)
  (and (transpiler-can-import? tr var)
	   (assoc var *variables*)))

(defun transpiler-add-wanted-variable (tr var)
  (when (transpiler-should-add-wanted-variable? tr var)
	(setf (href var (transpiler-wanted-variables-hash tr)) t)
    (adjoin! var (transpiler-wanted-variables tr))))

(defun transpiler-import-wanted-function (tr x)
  (unless (transpiler-defined-function tr x)
	(with-temporary (transpiler-currently-imported-lambda tr)
					(when (assoc x (transpiler-exported-lambdas tr))
					  x)
      (transpiler-add-emitted-wanted-function tr x)
      (let fun (symbol-function x)
        (when (functionp fun)
	      (transpiler-sighten tr
      	    `((defun ,x ,(function-arguments fun)
		        ,@(function-body fun)))))))))

(defun transpiler-import-wanted-functions (tr)
  (mapcan (fn transpiler-import-wanted-function tr _)
    	  (transpiler-wanted-functions tr)))

(defun transpiler-import-wanted-variables (tr)
  (transpiler-sighten tr
    (mapcar (fn (unless (transpiler-defined-variable tr _)
				  `(defvar ,_ ,(assoc-value _ *variables*))))
		    (transpiler-wanted-variables tr))))

(defun transpiler-import-from-environment (tr)
  (append (transpiler-import-wanted-functions tr)
		  (transpiler-import-wanted-variables tr)))
