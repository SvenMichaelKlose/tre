;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
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

(defun transpiler-expand-and-generate-code (tr forms)
  (transpiler-generate-code tr (transpiler-expand tr forms)))

(defmacro with-gensym-assignments ((&rest pairs) &rest body)
  `(with-gensym ,(mapcar #'first (group pairs 2))
	 `(with ,(mapcar #'((x)
					      (list 'QUASIQUOTE x))
					 pairs)
	    ,(list 'QUASIQUOTE-SPLICE (cons 'QUOTE body)))))
;,,@.'body)))))

(defmacro assoc-update (key value alist)
  (with-gensym-assignments (k key
							v value)
    `(aif (assoc ,k ,alist)
	     `(setf (cdr !) ,v)
	     `(setf ,alist (acons ,k ,v ,alist)))))

(defun transpiler-collect-wanted (tr pass funlist)
  (let out nil
    (dolist (x funlist out)
      (unless (member x (transpiler-emitted-wanted-functions tr))
		(setf (transpiler-emitted-wanted-functions tr)
			  (push x (transpiler-emitted-wanted-functions tr)))
	    (let fun (symbol-function x)
	      (when (functionp fun)
		    (setf out (nconc out
						     (funcall pass tr
								     `((defun ,x ,(function-arguments fun)
							             ,@(function-body fun))))))))))))

;; User code must have been sightened by TRANSPILER-SIGHT.
(defun transpiler-transpile (tr forms)
  (unless (eq t (transpiler-unwanted-functions tr))
    (format t "; Collecting dependencies...~%")
    (let wanted-funs (transpiler-collect-wanted tr
	  				   #'((tr x)
		   				    (transpiler-preexpand-and-expand tr x))
	  				   (transpiler-wanted-functions tr))
  	  (format t "; Generating code...~%")
  	  (transpiler-concat-string-tree
		(append (transpiler-generate-code tr (reverse wanted-funs))
		        (transpiler-expand-and-generate-code tr forms))))))

(defun transpiler-sighten (tr x)
  (let tmp (transpiler-preexpand tr x)
	(transpiler-expression-expand tr tmp)
	tmp))

(defun transpiler-sighten-files (tr files)
  (mapcan (fn (format t "; Reading file '~A'...~%" _)
      		  (with-open-file f (open _ :direction 'input)
        	    (transpiler-sighten tr (read-many f))))
		  files))
