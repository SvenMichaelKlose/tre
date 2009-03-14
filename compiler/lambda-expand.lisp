;;;;; TRE compiler
;;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; LAMBDA expansion.

(defmacro with-lambda-call ((args vals body call) &rest exec-body)
  (with-gensym (tmp fun)
    `(with (,tmp ,call
            ,fun (second (car ,tmp))
            ,args (lambda-args-expanded ,fun)
            ,vals (lambda-call-vals ,tmp)
            ,body (lambda-body ,fun))
       ,@exec-body)))

;;;; FUNINFO manipulators

(defun funinfo-make-lexical (fi)
  (unless (funinfo-lexical fi)
    (let lexical (gensym)
	  (setf (funinfo-lexical fi) lexical)
	  (funinfo-env-add fi lexical))))

(defun funinfo-make-ghost (fi)
  (unless (funinfo-ghost fi)
    (let ghost (gensym)
	  (setf (funinfo-ghost fi) ghost)
	  (setf (funinfo-args fi)
		    (cons ghost (funinfo-args fi)))
	  (funinfo-env-add fi ghost))))

(defun funinfo-link-lexically (fi fi-child)
  (funinfo-make-lexical fi)
  (funinfo-make-ghost fi-child))

;; Make lexical path to desired variable.
(defun funinfo-setup-lexical-links (fi fi-child var)
  (unless fi
	(error "couldn't find ~A in environment" var))
  (funinfo-add-free-var fi-child var)
  (funinfo-link-lexically fi fi-child)
  (if (funinfo-env-pos fi var)
	  (funinfo-add-lexical fi var)
      (funinfo-setup-lexical-links (funinfo-parent fi) fi var)))

;;; Pass lexical up one step through ghost.

(defun make-lexical-place-expr (fi fi-child var)
  `(%vec ,(funinfo-ghost fi-child)
		 ,(funinfo-lexical-pos fi var)))

(defun make-lexical-1 (fi fi-child var)
  (if (funinfo-env-pos fi var)
	  (make-lexical-place-expr fi fi-child var)
	  (make-lexical-1 (funinfo-parent fi) fi var)))

(defun make-lexical-0 (fi fi-child x)
  (funinfo-setup-lexical-links fi fi-child x)
  (let ret (make-lexical-1 fi fi-child x)
	`(%vec ,(make-lexical fi fi-child (second ret)) ,(third ret))))

(defun make-stackplace (fi fi-child x)
  (if (funinfo-env-pos fi x)
      `(%stack ,(funinfo-env-pos fi x))
	  x))

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
	  ; self-reference).
      (and (not (eq (funinfo-lexical fi) x))
		   (funinfo-lexical-pos fi x))
        `(%vec ,(vars-to-stackplaces-atom fi (funinfo-lexical fi))
			   ,(funinfo-lexical-pos fi x))
	  ; Emit argumet instead of its stack-place.
      (and (not (funinfo-lexical-pos fi x))
		   (funinfo-arg? fi x))
		x
	  ; Emit stack place.
      (funinfo-env-pos fi x)
        `(%stack ,(funinfo-env-pos fi x))
	  ; Emit lexical place (outside the function).
	  (make-lexical (funinfo-parent fi) fi x))))

(defun vars-to-stackplaces (fi x)
  (if (consp x)
      (if
		(lambda? x) ; Add variables to ignore in subfunctions.
	      `#'(,@(make-lambda-funinfo fi)
			  ,(lambda-args x)
			     ,@(vars-to-stackplaces fi (lambda-body x)))
	    (%slot-value? x)
	      `(%slot-value ,(vars-to-stackplaces fi (second x)) ,(third x))
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
    (mapcan (fn (unless (and (not (eq (funinfo-lexical fi) _))
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
	(funinfo-add-closure fi
        `(defun ,name ,(append (make-lambda-funinfo fi-child)
							   (funinfo-args fi-child))
		   ,@(lambda-body x)))
	name))

(defun lambda-export-transform (fi x)
  (with (fi-child (funinfo-get-child-funinfo fi)
		 exported (lambda-export-make-exported fi fi-child x))
	 (if (funinfo-ghost fi-child)
    	 `(%funref ,exported ,(funinfo-lexical fi))
		 exported)))

;;; Export gathering

(defun lambda-export-gather-child-make-funinfo (fi)
  (let args (lambda-args x)
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
    (and export-lambdas
		 (lambda? x))
	  (if gather
          (lambda-export-gather fi x)
          (lambda-export-transform fi x))
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

;; XXX (defun lambda-expand-0 (fi body export-lambdas)
(defun lambda-embed-or-export (fi body export-lambdas)
  (when export-lambdas
    (lambda-expand-tree fi body export-lambdas t))
  (lambda-embed-or-export-transform fi body export-lambdas))

(defun lambda-expand (fun body &optional (export-lambdas t))
  (with (forms  (argument-expand-names 'lambda-expansion
									   (function-arguments fun))
         fi     (make-funinfo :env forms
							  :args forms))
    (values (lambda-embed-or-export fi body export-lambdas) fi)))
