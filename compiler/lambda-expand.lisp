;;;;; TRE compiler
;;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; LAMBDA expansion.

(defvar *lambda-exported-closures* nil)
(defvar *lambda-expand-always-have-funref* nil)

(defun lambda-expand-add-closures (x)
  (nconc! *lambda-exported-closures* x))

(defun lambda-expand-add-closure (x)
  (lambda-expand-add-closures (list x)))

(defmacro with-lambda-call ((args vals body call) &rest exec-body)
  (with-gensym (tmp fun)
    `(with (,tmp ,call
            ,fun (second (car ,tmp))
            ,args (lambda-args-expanded ,fun)
            ,vals (lambda-call-vals ,tmp)
            ,body (lambda-body ,fun))
       ,@exec-body)))

;;; Pass lexical up one step through ghost.

(defun make-lexical-place-expr (fi fi-child var)
  `(%vec ,(funinfo-ghost fi-child)
		 ,(funinfo-lexical-pos fi var)))

(defun make-lexical-1 (fi fi-child var)
  (if (funinfo-env-pos fi var)
	  (make-lexical-place-expr fi fi-child var)
	  (make-lexical-1 (funinfo-parent fi)
					  fi
					  var)))

(defun make-lexical-0 (fi fi-child x)
  (funinfo-setup-lexical-links fi fi-child x)
  (let ret (make-lexical-1 fi fi-child x)
	`(%vec ,(make-lexical fi
						  fi-child
						  (second ret))
		   ,(third ret))))

(defun make-lexical (fi fi-child x)
  (if (eq (funinfo-ghost fi-child) x)
	  (vars-to-stackplaces-atom fi x)
	  (make-lexical-0 fi fi-child x)))

(defun vars-to-stackplaces-atom (fi x)
  (when x
    (if
	  ; Skip item, if it's not in the environment.
   	  (not (funinfo-in-this-or-parent-env? fi x))
		x
	  ; Emit lexical place, except the lexical array itself (it can
	  ; self-reference for child functions).
      (and (not (eq (funinfo-lexical fi)
					 x))
		   (funinfo-lexical-pos fi x))
        `(%vec ,(vars-to-stackplaces-atom fi
										  (funinfo-lexical fi))
			   ,(funinfo-lexical-pos fi x))
	  ; Emit argumet instead of its stack-place.
      (and (not (funinfo-lexical-pos fi x))
		   (funinfo-arg? fi x))
		x
	  ; Emit stack place.
      (funinfo-env-pos fi x)
		`(%stack ,(funinfo-env-pos fi x))
	  ; Emit lexical place (outside the function).
	  (make-lexical (funinfo-parent fi)
					fi
					x))))

(defun vars-to-stackplaces (fi x)
  (if (consp x)
      (if
		(%quote? x)
		  x
		(lambda? x) ; Add variables to ignore in subfunctions.
	      `#'(,@(lambda-funinfo-expr x)
			  ,(lambda-args x)
			     ,@(vars-to-stackplaces fi
										(lambda-body x)))
	    (%slot-value? x)
	      `(%slot-value ,(vars-to-stackplaces fi
											  (second x))
						,(third x))
	    (cons (vars-to-stackplaces fi x.)
			  (vars-to-stackplaces fi .x)))
	  (vars-to-stackplaces-atom fi x)))

;;;; LAMBDA inlining

(defun make-inline-body (stack-places values body)
  `(vm-scope
	 ,@(mapcar #'((stack-place init-value)
				  `(%setq ,stack-place ,init-value))
			   stack-places values)
     ,@body))

(defun lambda-call-embed (fi lambda-call export-lambdas gather)
  (with-lambda-call (args vals body lambda-call)
    (with ((a v) (assoc-splice (argument-expand 'local-var-fun args vals)))
	  ; Add lambda-call arguments to the parent function's arguments
	  ; temporarily to make stack-places; so the stack-places can be
	  ; reused by the next lambda-call on the same level.
      ;(with-funinfo-env-temporary fi args
      (dolist (i a)
		(unless (funinfo-env-pos fi i)
		  (funinfo-env-add fi i)))
      (make-inline-body
		  (vars-to-stackplaces fi a)
      	  v
		  (lambda-expand-gather-or-transform fi body export-lambdas gather)))));)

;;; Export

(defun make-var-declarations (fi)
  (vars-to-stackplaces fi
    (mapcan (fn (unless (and (not (eq (funinfo-lexical fi)
									  _))
						 	 (or (funinfo-arg? fi _)
						    	 (funinfo-lexical-pos fi _)))
				  `((%var ,_))))
	        (funinfo-env fi))))

(defun make-copiers-to-lexicals (fi)
  (let lexicals (funinfo-lexicals fi)
	(when lexicals
	  (let lex-sym (vars-to-stackplaces fi (funinfo-lexical fi))
    	`((%setq ,lex-sym (make-array ,(length lexicals)))
          ,@(mapcan (fn (awhen (funinfo-lexical-pos fi _)
				  	      `((%set-vec ,lex-sym
						 	      	  ,!
								  	  ,_))))
					(append (list (funinfo-lexical fi))
						    (funinfo-args fi))))))))

(defun make-function-epilogue (fi body)
  `(,@(when (atom body.) ; Preserve first atom.
	    (list body.))
	,@(make-var-declarations fi)
	,@(make-copiers-to-lexicals fi)
    ,@(if (atom body.)
		  .body
		  body)))

(defun lambda-export-make-exported (fi fi-child x)
  (with-gensym name
	(lambda-expand-add-closure
        `((defun ,name ,(append (make-lambda-funinfo fi-child)
							    (funinfo-args fi-child))
		    ,@(lambda-body x))))
	name))

(defun lambda-export-transform (fi x)
  (with (fi-child (funinfo-get-child-funinfo fi)
		 exported (lambda-export-make-exported fi fi-child x))
	(if
	  (funinfo-ghost fi-child)
    	`(%funref ,exported ,(funinfo-lexical fi))
	  *lambda-expand-always-have-funref*
    	`(%funref ,exported nil)
	  exported)))

;;; Export gathering

(defun lambda-export-gather-child-make-funinfo (fi)
  (with ((args exported-closures) (lambda-expand (lambda-args x)
												 t))
	(lambda-expand-add-closures exported-closures)
    (make-funinfo :env args
			      :args args
			      :parent fi)))

;; Do a gathering expansion. Builds FUNINFO tree.
(defun lambda-export-gather (fi x)
  (let fi-child (lambda-export-gather-child-make-funinfo fi)
    (lambda-expand-gather fi-child
	  				      (lambda-body x)
			   			  t)
    (funinfo-add-gathered-closure-info fi fi-child))
  nil)

;;;; Toplevel

(defun lambda-expand-branch (fi x export-lambdas gather)
  (if
    (lambda-call? x)
      (lambda-call-embed fi x export-lambdas gather)
    (lambda? x)
	  (if export-lambdas
	  	  (if gather
              (lambda-export-gather fi x)
              (lambda-export-transform fi x))
		  `#'(,@(make-lambda-funinfo-if-missing x
				  (make-funinfo :env (lambda-args x)
								:args (lambda-args x)
								:parent fi))
			  ,(lambda-args x)
			  ,@(lambda-body x)))
	x))

(defun lambda-expand-tree (fi body export-lambdas gather)
  (tree-walk body
			 :ascending
			   (fn lambda-expand-branch fi _ export-lambdas gather)))

(defun lambda-expand-transform (fi body export-lambdas)
  (vars-to-stackplaces fi (lambda-expand-tree fi body export-lambdas nil)))

(defun lambda-expand-gather (fi body export-lambdas)
  (vars-to-stackplaces fi (lambda-expand-tree fi body export-lambdas t)))

(defun lambda-expand-gather-or-transform (fi body export-lambdas gather)
  (if gather
      (lambda-expand-gather fi body export-lambdas)
      (lambda-expand-transform fi body export-lambdas)))

(defun lambda-embed-or-export-transform (fi body export-lambdas)
  (make-function-epilogue fi
      (lambda-expand-transform fi body export-lambdas)))

(defun lambda-embed-or-export (fi body export-lambdas)
  (when export-lambdas
    (lambda-expand-tree fi body export-lambdas t))
  (lambda-embed-or-export-transform fi body export-lambdas))

(defun lambda-expand-0 (x export-lambdas)
  (with (forms (argument-expand-names
			       'transpiler-lambda-expand
			       (lambda-args x.))
         imported	(get-lambda-funinfo x.)
         fi			(or imported
						(make-funinfo :env forms
							  		  :args forms)))
    (values
	    `#'(,@(make-lambda-funinfo-if-missing x. fi)
		    ,(lambda-args x.)
            ,@(funcall (if imported
						   #'lambda-embed-or-export-transform
						   #'lambda-embed-or-export)
				       fi
                       (lambda-body x.)
				       export-lambdas))
		*lambda-exported-closures*)))

(defun lambda-expand (x export-lambdas)
  "Expand top-level LAMBDA expressions."
  (with (exported-closures nil
		 lambda-exp-r
  		     #'((x)
				  (if (atom x)
	  				  x
	  				  (cons (if (lambda? x.)
							    (with ((new-x new-exported-closures)
						   			       (lambda-expand-0 x
															export-lambdas))
				  				  (append! exported-closures
										   new-exported-closures)
								  new-x)
								(lambda-exp-r x.))
		    				(lambda-exp-r .x)))))
	(values (lambda-exp-r x)
			exported-closures)))
