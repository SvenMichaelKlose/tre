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

;;;; LAMBDA inlining

(defun lambda-expand-make-inline-body (stack-places values body)
  `(%%vm-scope
	 ,@(mapcar #'((stack-place init-value)
				    `(%setq ,stack-place ,init-value))
			   stack-places values)
     ,@body))

(defun lambda-call-embed (fi lambda-call export-lambdas?)
  (with-lambda-call (args vals body lambda-call)
    (with ((a v) (assoc-splice (argument-expand 'dummy-in-lambda-call-embed
												args vals)))
	  (funinfo-env-add-many fi a)
	  (lambda-expand-tree fi
                          (lambda-expand-make-inline-body a v body)
		                  export-lambdas?))))

;;; Export

(defun lambda-export-make-exported (fi x)
  (with-gensym exported-name
    (let fi-child (lambda-make-funinfo (lambda-args x) fi)
	  (funinfo-make-ghost fi-child)
	  (lambda-expand-tree fi-child (lambda-body x) t)
      (let argdef (append (awhen (funinfo-ghost fi-child)
						    (list !))
						  (lambda-args x))
		(push (cons exported-name argdef) *closure-argdefs*)
	    (transpiler-add-exported-closure *current-transpiler*
            `((defun ,exported-name ,(append (make-lambda-funinfo fi-child)
											 argdef)
		        ,@(lambda-body x))))
	  (values exported-name fi-child)))))

(defun lambda-export (fi x)
  (with ((exported-name fi-child) (lambda-export-make-exported fi x))
    `(%%funref ,exported-name
               ,(funinfo-sym fi-child))))

;;;; Toplevel

(defun lambda-expand-tree-unexported-lambda (fi x)
  (with (new-fi (or (when (lambda-funinfo x)
					  (get-lambda-funinfo x))
					(lambda-make-funinfo (lambda-args x) fi))
		 body (lambda-expand-tree-0 new-fi (lambda-body x) nil))
	(copy-lambda x :info new-fi
				   :body body)))

(defun lambda-expand-tree-cons (fi x export-lambdas?)
  (if
    (lambda-call? x)
      (lambda-call-embed fi x export-lambdas?)
    (lambda? x)
	  (if export-lambdas?
          (lambda-export fi x)
		  (lambda-expand-tree-unexported-lambda fi x))
	(lambda-expand-tree-0 fi x export-lambdas?)))

(defun lambda-expand-tree-0 (fi x export-lambdas?)
  (if
	(atom x)
	  x
	(atom x.)
	  (cons x.
			(lambda-expand-tree-0 fi .x export-lambdas?))
	(cons (lambda-expand-tree-cons fi x. export-lambdas?)
		  (lambda-expand-tree-0 fi .x export-lambdas?))))

(defun lambda-expand-tree (fi x export-lambdas?)
  (let expanded-body (lambda-expand-tree-0 fi x export-lambdas?)
    (place-expand-0 fi expanded-body)
	expanded-body))

(defun lambda-expand-0 (x export-lambdas? &key (lambda-name nil))
  (with (forms (argument-expand-names 'transpiler-lambda-expand
			                          (lambda-args x))
         imported	(get-lambda-funinfo x)
         fi			(or imported
						(lambda-make-funinfo forms *global-funinfo*)))
    (copy-lambda x
	             :name lambda-name
		         :info fi
		         :body (lambda-expand-tree fi (lambda-body x) export-lambdas?))))

(defun lambda-expand (x export-lambdas?)
  (with (lambda-exp-r
  		     #'((x)
				  (if
					(atom x)
	  				  x
				    (named-lambda? x)
					  (lambda-expand-0 ..x. export-lambdas?  :lambda-name .x.)
	  				(lambda? x)
				      (lambda-expand-0 x export-lambdas?)
					(cons (lambda-exp-r x.)
		    			  (lambda-exp-r .x)))))
	(lambda-exp-r x)))

(defun transpiler-lambda-expand (tr x)
  (lambda-expand x (transpiler-lambda-export? tr)))
