;;;;; TRE compiler
;;;;; Copyright (c) 2005-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; LAMBDA expansion.

;;;; XXX clean-up plan
;;;; Make this functions a layer of FUNINFO to get rid of the first
;;;; FI argument as well as the FUNINFO prefixes.

(defvar *lambda-exported-closures* nil)

(defun lambda-expand-add-closures (x)
  (nconc! *lambda-exported-closures* x))

(defun lambda-expand-add-closure (x)
  (lambda-expand-add-closures (list x)))

;;;; LAMBDA inlining

(defun lambda-expand-make-inline-body (stack-places values body)
  `(vm-scope
	 ,@(mapcar #'((stack-place init-value)
				    `(%setq ,stack-place ,init-value))
			   stack-places values)
     ,@body))

(defun lambda-call-embed (fi lambda-call export-lambdas?)
  (with-lambda-call (args vals body lambda-call)
    (with ((a v) (assoc-splice (argument-expand 'dummy-in-lambda-call-embed args vals)))
	  ; Add lambda-call arguments to the parent function's arguments
	  ; temporarily to make stack-places; so the stack-places can be
	  ; reused by the next lambda-call on the same level.
      ;(with-funinfo-env-temporary fi args
	  (funinfo-env-add-many fi a)
      (lambda-expand-make-inline-body a v
	      (lambda-expand-tree fi body export-lambdas?)))));)

;;; Export

(defun lambda-export-make-exported (fi x)
  (with-gensym exported-name
    (let fi-child (make-funinfo :parent fi
								:args (lambda-args x))
	  (when (transpiler-stack-locals? *current-transpiler*)
		(funinfo-make-ghost fi-child))
	  (lambda-expand-tree fi-child (lambda-body x) t)
      (let argdef (append (awhen (funinfo-ghost fi-child)
						    (list !))
						  (lambda-args x))
		(push (cons exported-name argdef) *closure-argdefs*)
        (lambda-expand-add-closure
            `((defun ,exported-name ,(append (make-lambda-funinfo fi-child)
											 argdef)
		        ,@(lambda-body x))))
	  (values exported-name fi-child)))))

(defun lambda-export (fi x)
  (with ((exported-name fi-child) (lambda-export-make-exported fi x))
    `(%%funref ,exported-name
               ,(funinfo-sym fi-child))))

;;;; Toplevel

(defun lambda-expand-branch (fi x export-lambdas?)
  (if
    (lambda-call? x)
      (lambda-call-embed fi x export-lambdas?)
    (lambda? x)
	  (if export-lambdas?
          (lambda-export fi x)
		  (lambda-w/-missing-funinfo x (make-funinfo :args (lambda-args x)
												    :parent fi)))
	x))

(defun lambda-expand-tree-0 (fi body export-lambdas?)
  (tree-walk body
		     :ascending
		         (fn lambda-expand-branch fi _ export-lambdas?)))

(defun lambda-expand-tree (fi body export-lambdas?)
  (let expanded-body (lambda-expand-tree-0 fi body export-lambdas?)
    (place-expand-0 fi expanded-body)
	expanded-body))

(defun lambda-embed-or-export-transform (fi body export-lambdas?)
  (let expanded-body (lambda-expand-tree-0 fi body export-lambdas?)
    (place-expand-0 fi expanded-body)
	expanded-body))

(defun lambda-expand-0 (x export-lambdas? &key (function-name nil))
  (with (forms (argument-expand-names
			       'transpiler-lambda-expand
			       (lambda-args x))
         imported	(get-lambda-funinfo x)
         fi			(or imported
						(make-funinfo :parent *global-funinfo*
									  :args forms)))
    (values
	    `(function ,@(awhen function-name
					   (setf (funinfo-name fi) !)
					   (list !))
	       ,(append (lambda-head-w/-missing-funinfo x fi)
                    (lambda-embed-or-export-transform fi (lambda-body x)
												      export-lambdas?)))
		*lambda-exported-closures*)))

(defun lambda-expand (x export-lambdas?)
  "Expand top-level LAMBDA expressions."
  (with (exported-closures nil
		 lambda-exp-r
  		     #'((x)
				  (if
					(atom x)
	  				  x
				    (named-function-expr? x)
					  (with ((new-x new-exported-closures) (lambda-expand-0 ..x. export-lambdas?
																			:function-name .x.))
    					(append! exported-closures
		     			         new-exported-closures)
						new-x)
					    
	  				(lambda? x)
  					  (with ((new-x new-exported-closures) (lambda-expand-0 x export-lambdas?))
    				    (append! exported-closures
		     			     	 new-exported-closures)
						new-x)
					(cons (lambda-exp-r x.)
		    			  (lambda-exp-r .x)))))
	(values (lambda-exp-r x)
			exported-closures)))
