;;;;; TRE compiler
;;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; LAMBDA expansion.

;;;; XXX clean-up plan
;;;; Make this functions a layer of FUNINFO to get rid of the first
;;;; FI argument as well as the FUNINFO prefixes.

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

;;;; LAMBDA inlining

(defun make-inline-body (stack-places values body)
  `(vm-scope
	 ,@(mapcar #'((stack-place init-value)
				    `(%setq ,stack-place ,init-value))
			   stack-places values)
     ,@body))

(defun funinfo-find-doubles (fi x)
  (when x
    (if (funinfo-in-args-or-env? fi x.)
	    (cons x.
			  (funinfo-find-doubles fi .x))
	    (funinfo-find-doubles fi .x))))

(defun funinfo-rename-doubles (doubles)
  (when doubles
	(cons (cons doubles. (gensym))
	  	  (funinfo-rename-doubles .doubles))))

(defun lambda-call-embed (fi lambda-call export-lambdas)
  (with-lambda-call (args vals body lambda-call)
    (with ((a v) (assoc-splice (argument-expand 'local-var-fun args vals)))
	  ; Add lambda-call arguments to the parent function's arguments
	  ; temporarily to make stack-places; so the stack-places can be
	  ; reused by the next lambda-call on the same level.
      ;(with-funinfo-env-temporary fi args
      (with-temporary (funinfo-renamed-vars fi)
      				  (append (funinfo-rename-doubles
          				  		  (funinfo-find-doubles fi a))
							  (funinfo-renamed-vars fi))
	    (let renamed-args (place-expand fi (funinfo-rename-many fi a))
	      (funinfo-env-add-many fi renamed-args)
          (make-inline-body
		      renamed-args ;(place-expand fi a)
      	      v
		      (lambda-expand-tree fi body export-lambdas)))))));)

;;; Export

(defun make-var-declarations (fi)
    (mapcan (fn (unless (or (transpiler-stack-locals? *current-transpiler*)
 							);(and (not (eq _ (funinfo-lexical fi)))
							; (funinfo-lexical-pos fi _)))
				  `((%var ,_))))
	        (funinfo-env fi)))

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
	,@(make-copiers-to-lexicals fi)
    ,@(if (atom body.)
		  .body
		  body)))

(defun lambda-export-rename (fi fi-child)
  (setf (funinfo-renamed-vars fi-child)
		(append (funinfo-renamed-vars fi)
		  		(funinfo-rename-doubles
					(funinfo-find-doubles fi (funinfo-args fi-child)))))
  (setf (funinfo-args fi-child)
		(funinfo-rename-many fi-child (funinfo-args fi-child))))

(defun lambda-export-make-exported (fi x)
  (with-gensym exported-name
    (let fi-child (make-funinfo :parent fi
								:args (lambda-args x))
;	  (lambda-export-rename fi fi-child)
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
