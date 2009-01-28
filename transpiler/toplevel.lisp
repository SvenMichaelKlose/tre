;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

(defun transpiler-add-wanted-function (tr fun)
  (unless (or (member fun (transpiler-wanted-functions tr))
			  (or (eq t (transpiler-unwanted-functions tr))
				  (member fun (transpiler-unwanted-functions tr)))
			  (assoc fun (expander-macros
						   (expander-get
							 (transpiler-macro-expander tr)))))
	(setf (transpiler-wanted-functions tr)
		  (nconc (transpiler-wanted-functions tr) (list fun)))))

(defun transpiler-add-wanted-variable (tr var)
  (when (and (not (member var (transpiler-defined-variables tr)))
			 (assoc var *variables*))
    (adjoin! var (transpiler-wanted-variables tr))))

(defun transpiler-expand-and-generate-code (tr forms)
  (transpiler-generate-code tr (transpiler-expand tr forms)))

(defmacro with-gensym-assignments ((&rest pairs) &rest body)
  `(with-gensym ,(mapcar #'first (group pairs 2))
	 `(with ,(mapcar #'((x)
					      (list 'QUASIQUOTE x))
					 pairs)
	    ,(list 'QUASIQUOTE-SPLICE (cons 'QUOTE body)))))

(defmacro assoc-update (key value alist)
  (with-gensym-assignments (k key
							v value)
    `(aif (assoc ,k ,alist)
	     `(setf (cdr !) ,v)
	     `(setf ,alist (acons ,k ,v ,alist)))))

(defun transpiler-collect-wanted-functions (tr)
  (let out nil
    (dolist (x (transpiler-wanted-functions tr) out)
      (unless (or (member x (transpiler-emitted-wanted-functions tr))
				  (transpiler-function-arguments tr x)
				  (member x (transpiler-defined-functions tr)))
	    (push! x (transpiler-emitted-wanted-functions tr))
	    (let fun (symbol-function x)
	      (when (functionp fun)
		    (setf out (nconc out
						     (transpiler-preexpand-and-expand tr
							   `((defun ,x ,(function-arguments fun)
							       ,@(function-body fun))))))))))))

(defun transpiler-collect-wanted-variables (tr)
  (transpiler-preexpand-and-expand tr
    (mapcar (fn (let v (assoc-value _ *variables*)
				  `(defvar ,_ ,v)))
		    (transpiler-wanted-variables tr))))

(defun transpiler-transpile-wanted-functions (tr)
  (transpiler-generate-code tr
	(append (transpiler-collect-wanted-functions tr)
			(transpiler-collect-wanted-variables tr))))

;; User code must have been sightened by TRANSPILER-SIGHT.
(defun transpiler-transpile (tr forms)
  (unless (eq t (transpiler-unwanted-functions tr))
	(transpiler-expand-and-generate-code tr forms)))

(defun transpiler-sighten (tr x)
  (let tmp (transpiler-preexpand tr x)
	(transpiler-expression-expand tr tmp)
	tmp))

(defun transpiler-sighten-files (tr files)
  (mapcan (fn (format t "(LOAD \"~A\")~%" _)
      		  (with-open-file f (open _ :direction 'input)
        	    (transpiler-sighten tr (read-many f))))
		  files))
