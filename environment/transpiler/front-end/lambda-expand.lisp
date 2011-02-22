;;;;; TRE compiler
;;;;; Copyright (c) 2005-2010 Sven Klose <pixel@copei.de>

(defun lambda-make-funinfo (args parent)
  (with (argnames (argument-expand-names 'lambda-expand args)
         fi (make-funinfo :args argnames
					      :parent parent))
	(when (transpiler-stack-locals? *current-transpiler*)
      (funinfo-env-add-many fi argnames))
	(funinfo-env-add fi '~%ret)
	fi))

;;;; Inlining

(defun lambda-expand-make-inline-body (stack-places values body)
  `(%%vm-scope
	 ,@(mapcar #'((stack-place init-value)
				    `(%setq ,stack-place ,init-value))
			   stack-places values)
     ,@body))

(defun lambda-call-embed (fi lambda-call export-lambdas?)
  (with-lambda-call (args vals body lambda-call)
    (with ((a v) (assoc-splice (argument-expand 'dummy-in-lambda-call-embed args vals)))
	  (funinfo-env-add-many fi a)
	  (lambda-expand-tree fi (lambda-expand-make-inline-body a v body) export-lambdas?))))

;;; Export

(defun lambda-export-make-exported (fi x)
  (with-gensym exported-name
    (let fi-exported (lambda-make-funinfo (lambda-args x) fi)
	  (funinfo-make-ghost fi-exported)
	  (lambda-expand-tree fi-exported (lambda-body x) t)
      (let argdef (append (awhen (funinfo-ghost fi-exported)
						    (list !))
						  (lambda-args x))
		(push (cons exported-name argdef) *closure-argdefs*)
	    (transpiler-add-exported-closure *current-transpiler*
            `((defun ,exported-name ,(append (make-lambda-funinfo fi-exported) argdef)
		        ,@(lambda-body x)))))
	  (values exported-name fi-exported))))

(defun lambda-export (fi x)
  (with ((exported-name fi-exported) (lambda-export-make-exported fi x))
    `(%%funref ,exported-name
               ,(funinfo-sym fi-exported))))

;;;; Toplevel

(defun lambda-expand-tree-unexported-lambda (fi x)
  (with (new-fi (or (when (lambda-funinfo x)
					  (get-lambda-funinfo x))
					(lambda-make-funinfo (lambda-args x) fi))
		 body (lambda-expand-tree-0 new-fi (lambda-body x) nil))
	(copy-lambda x :info new-fi :body body)))

(defun lambda-expand-tree-cons (fi x export-lambdas?)
  (?
    (lambda-call? x)
      (lambda-call-embed fi x export-lambdas?)
    (lambda? x)
	  (? export-lambdas?
         (lambda-export fi x)
		 (lambda-expand-tree-unexported-lambda fi x))
	(lambda-expand-tree-0 fi x export-lambdas?)))

(defun lambda-expand-tree-0 (fi x export-lambdas?)
  (?
	(atom x) x
	(atom x.) (cons x. (lambda-expand-tree-0 fi .x export-lambdas?))
	(cons (lambda-expand-tree-cons fi x. export-lambdas?)
		  (lambda-expand-tree-0 fi .x export-lambdas?))))

(defun lambda-expand-tree (fi x export-lambdas?)
  (aprog1 (lambda-expand-tree-0 fi x export-lambdas?)
    (place-expand-0 fi !)))

(defun lambda-expand-0 (x export-lambdas? &key (lambda-name nil))
  (let fi (or (get-lambda-funinfo x)
		      (lambda-make-funinfo (lambda-args x) *global-funinfo*))
    (copy-lambda x :info fi :body (lambda-expand-tree fi (lambda-body x) export-lambdas?))))

(defun lambda-expand (x export-lambdas?)
  (with (lambda-exp-r
  		     #'((x)
				  (?
					(atom x) x
	  				(lambda? x) (lambda-expand-0 x export-lambdas?)
					(cons (lambda-exp-r x.)
		    			  (lambda-exp-r .x)))))
	(lambda-exp-r x)))

(defun transpiler-lambda-expand (tr x)
  (lambda-expand x (transpiler-lambda-export? tr)))
