;;;;; TRE compiler
;;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
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

(defun make-inline-body (stack-places values body)
  `(vm-scope
	 ,@(mapcar #'((stack-place init-value)
				    `(%setq ,stack-place ,init-value))
			   stack-places values)
     ,@body))

(defun lambda-call-embed (fi lambda-call export-lambdas)
  (with-lambda-call (args vals body lambda-call)
    (with ((a v) (assoc-splice (argument-expand 'local-var-fun args vals)))
	  ; Add lambda-call arguments to the parent function's arguments
	  ; temporarily to make stack-places; so the stack-places can be
	  ; reused by the next lambda-call on the same level.
      ;(with-funinfo-env-temporary fi args
	  (funinfo-env-add-many fi a)
      (make-inline-body a v
	      (lambda-expand-tree fi body export-lambdas)))));)

;;; Export

(defun make-var-declarations (fi)
  (unless (transpiler-stack-locals? *current-transpiler*)
    (mapcar (fn `(%var ,_))
	        (funinfo-env fi))))

(defun make-copiers-to-lexicals (fi)
  (let-when lexicals (funinfo-lexicals fi)
	(let lex-sym (funinfo-lexical fi)
      `((%setq ,lex-sym (make-array ,(length lexicals)))
        ,@(mapcan (fn (awhen (funinfo-lexical-pos fi _)
				  	    `((%set-vec ,lex-sym ,! ,_))))
				  (append (list (funinfo-lexical fi))
						  (funinfo-args fi)))))))

(defun make-function-epilogue (fi body)
  `(,@(when (atom body.) ; Preserve first atom.
	    (list body.))
	,@(make-var-declarations fi)
	,@(place-expand fi (make-copiers-to-lexicals fi)) ; place-expand for C transpiler
    ,@(if (atom body.)
		  .body
		  body)))

(defun lambda-export-make-exported (fi x)
  (with-gensym exported-name
    (let fi-child (make-funinfo :parent fi
								:args (lambda-args x))
	  (lambda-expand-tree fi-child (lambda-body x) t)
      (lambda-expand-add-closure
          `((defun ,exported-name ,(append (make-lambda-funinfo fi-child)
							      		   (append (awhen (funinfo-ghost fi-child)
													 (list !))
												   (lambda-args x)))
		      ,@(lambda-body x))))
	  (values exported-name fi-child))))

(defun lambda-export (fi x)
  (with ((exported-name fi-child) (lambda-export-make-exported fi x))
    `(%%funref ,exported-name
               ,(funinfo-sym fi-child))))

;;;; Toplevel

(defun lambda-expand-branch (fi x export-lambdas)
  (if
    (lambda-call? x)
      (lambda-call-embed fi x export-lambdas)
    (lambda? x)
	  (if export-lambdas
          (lambda-export fi x)
		  `#'(,@(make-lambda-funinfo-if-missing x
				  (make-funinfo :args (lambda-args x)
								:parent fi))
			  ,(lambda-args x)
			  ,@(lambda-body x)))
	x))

(defun lambda-expand-tree (fi body export-lambdas)
  (place-expand fi
      (tree-walk body
			     :ascending
			         (fn lambda-expand-branch fi _ export-lambdas))))

(defun lambda-embed-or-export-transform (fi body export-lambdas)
  (make-function-epilogue fi
      (lambda-expand-tree fi body export-lambdas)))

(defun lambda-expand-0 (x export-lambdas)
  (with (forms (argument-expand-names
			       'transpiler-lambda-expand
			       (lambda-args x.))
         imported	(get-lambda-funinfo x.)
         fi			(or imported
						(make-funinfo :args forms)))
    (values
	    `#'(,@(make-lambda-funinfo-if-missing x. fi)
		    ,(lambda-args x.)
            ,@(lambda-embed-or-export-transform
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
						   			       (lambda-expand-0 x export-lambdas))
				  				  (append! exported-closures
										   new-exported-closures)
								  new-x)
								(lambda-exp-r x.))
		    				(lambda-exp-r .x)))))
	(values (lambda-exp-r x)
			exported-closures)))
