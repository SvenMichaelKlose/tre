;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

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
  (when (and (not (member var (transpiler-defined-variables tr)))
			 (assoc var *variables*))
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

(defun transpiler-expand-and-generate-code (tr forms)
  (transpiler-generate-code tr
	(transpiler-expand tr forms)))

;;; PUBLIC

;; User code must have been sightened by TRANSPILER-SIGHT.
(defun transpiler-transpile (tr forms)
  (unless (eq t (transpiler-unwanted-functions tr))
	(transpiler-expand-and-generate-code tr forms)))

(defun transpiler-sighten (tr x)
  (let tmp (transpiler-preexpand tr x)
	; Do an expression expand to collect the names of required
	; functions and variables. It is done again later when all
	; definitions are visible.
	(transpiler-expression-expand tr tmp)
	tmp))

(defun transpiler-sighten-files (tr files)
  (mapcan (fn (format t "(LOAD \"~A\")~%" _)
      		  (with-open-file f (open _ :direction 'input)
        	    (transpiler-sighten tr (read-many f))))
		  files))
