;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Import functions and variable from the environment.

(defun transpiler-should-add-wanted-function? (tr fun)
  (or (eq t (transpiler-unwanted-functions tr))
	  (member fun (transpiler-wanted-functions tr))
	  (member fun (transpiler-unwanted-functions tr))
	  (assoc fun (expander-macros
				   (expander-get
					 (transpiler-macro-expander tr))))))
	
(defun transpiler-add-wanted-function (tr fun)
  (unless (transpiler-should-add-wanted-function? tr fun)
	(nconc! (transpiler-wanted-functions tr)
			(list fun))))

(defun transpiler-add-wanted-variable (tr var)
  (when (and (assoc var *variables*)
			 (not (transpiler-defined-variable tr var)))
    (adjoin! var (transpiler-wanted-variables tr))))

(defun transpiler-import-wanted-functions (tr)
  (mapcan (fn (unless (transpiler-defined-function tr _)
    	        (push! _ (transpiler-emitted-wanted-functions tr))
	    	    (let fun (symbol-function _)
	              (when (functionp fun)
				    (transpiler-sighten tr
				      `((defun ,_ ,(function-arguments fun)
						             ,@(function-body fun))))))))
    	  (transpiler-wanted-functions tr)))

(defun transpiler-import-wanted-variables (tr)
  (transpiler-sighten tr
    (mapcar (fn (let v (assoc-value _ *variables*)
				  `(defvar ,_ ,v)))
		    (transpiler-wanted-variables tr))))

(defun transpiler-import-wanted-from-environment (tr)
  (append (transpiler-import-wanted-functions tr)
		  (transpiler-import-wanted-variables tr)))
