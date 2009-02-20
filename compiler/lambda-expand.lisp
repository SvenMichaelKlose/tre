;;;;; TRE compiler
;;;;; Copyright (C) 2005-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; LAMBDA expansion.
;;;;;
;;;;; This pass embeds functions which introduce local variables, allocating
;;;;; stack slots for the arguments of the embedded function.
;;;;; It also exports functions and creates function references with pointers
;;;;; to memory blocks of free variables.

(defmacro with-lambda-call ((args vals body call) &rest exec-body)
  "Bind local function call components to variables for exec-body."
  (with-gensym (tmp fun)
    `(with (,tmp ,call
            ,fun (second (car ,tmp))
            ,args (lambda-args-expanded ,fun)
            ,vals (lambda-call-vals ,tmp)
            ,body (lambda-body ,fun))
       ,@exec-body)))

;;; Stack setup

(defun make-stackplace (fi var )
  "Make stack-place. If the variable is not in the current environment,
   it is returned as is and added to the free-variable list of the funinfo."
  (aif (funinfo-env-pos fi var)
       `(%stack ,!)
       `(%vec %ghost ,(or (funinfo-free-var-pos fi var)
                          (progn
                            (funinfo-add-free-var fi var)
                            (funinfo-free-var-pos fi var))))))

(defun is-env-var? (fi var)
  "Check if symbol is a varable in the current environment."
  (when (atom var)
    (member var (apply #'append (funinfo-env fi)))))

(defun vars-to-stackplaces (fi body)
  "Replaces variables by stack operations. Returns modified body.
   Free variables are added to free-vars of the funinfo."
  (tree-walk body
	:dont-ascend-after-if
	  (fn (or (%slot-value? _)
			  (lambda? _)))
    :ascending
      (fn (if
		    (lambda? _) ; Add variables to ignore in subfunctions.
			  (vars-to-stackplaces fi _ )
			(%slot-value? _)
			  `(%slot-value ,(vars-to-stackplaces fi (second _)) ,(third _))
           	(is-env-var? fi _)
              (make-stackplace fi _)
			_))))

;;; Stack and lexical array

;(defun make-stackplace (fi var )
;  "Make stack-place. If the variable is not in the current environment,
;   it is returned as is and added to the free-variable list of the funinfo."
;  ;; Immediate function argument (shouldn't be on stack)
;  (if (member var (funinfo-args fi))
;	  (make-lexical-place fi var)
;      (aif (funinfo-env-pos fi var)
;           `(%stack ,!)
;		   (aif (funinfo-parent-lexicals-pos fi var)
;	            `(aref %ghost ,!)
;				 (progn
;				   (unless (funinfo-free-var-pos fi var)
;                     (funinfo-add-free-var fi var))
;				   var)))))
;
;(defun is-env-var? (fi var)
;  "Check if symbol is a varable in the current environment."
;  (and var
;	   (atom var)
;       (member var
;			  (apply #'append (funinfo-free-vars fi)
;		   					  (funinfo-env fi)))))
;
;(defun make-lexical-place (fi var )
;  var)
;  (if (or (not var)
;		  (eq '%%lexical var))
;	  var
;  	  (aif (funinfo-lexicals-pos fi var)
;	       `(aref %%lexical ,!)
;	       var)))
;
;(defun vars-to-stackplaces (fi body)
;  "Replaces variables by stack operations. Returns modified body.
;   Free variables are added to free-vars of the funinfo."
;  (tree-walk body
;	:dont-ascend-after-if
;	  (fn (or (%slot-value? _)
;			  (lambda? _)))
;    :ascending
;      (fn (if
;		    (lambda? _) ; Add variables to ignore in subfunctions.
;			  (vars-to-stackplaces fi _ )
;			(%slot-value? _)
;			  `(%slot-value ,(vars-to-stackplaces fi (second _)) ,(third _))
;           	(is-env-var? fi _)
;              (make-stackplace fi _)
;			(make-lexical-place fi _)))))

;;; LAMBDA inlining

(defun make-inline-body (stack-places values body)
  "Make body with stack variable initialisers."
  `(vm-scope
	 ,@(mapcan #'((stack-place init-value)
				  `((%var ,stack-place)
					(%setq ,stack-place ,init-value)))
			   stack-places values)
     ,@body))

(defun lambda-call-embed (fi lambda-call export-lambdas)
  "Replace local LAMBDA expression by its body using stack variables."
  (with-lambda-call (args vals body lambda-call)
    (with ((a v) (assoc-splice (argument-expand 'local-var-fun args vals)))
	  ; Add lambda-call arguments to the parent function's arguments
	  ; temporarily to make stack-places; so the stack-places can be
	  ; reused by the next lambda-call on the same level.
      (with-funinfo-env-temporary fi args
        (make-inline-body
			(vars-to-stackplaces fi a)
      		v
			(lambda-embed-or-export fi body export-lambdas))))))

;;; LAMBDA export

(defun make-varblock-inits (fi)
  (let lexicals (funinfo-lexicals fi)
    (mapcar (fn `(%%usetf-aref ,(make-stackplace fi _)
							   '%%lexical
						 	   ,(position _ lexicals)))
		    lexicals)))

(defun make-lexical-body (fi body)
  (let lexicals (funinfo-lexicals fi)
	(unless (member '%%lexical (apply #'append (funinfo-env fi)))
      (funinfo-env-add fi '%%lexical))
    `((vm-scope
        (%var %%lexical)
        (%setq %%lexical
		       (make-array ,(length lexicals)))
        ,@(make-varblock-inits fi)
	    ,@body))))

;;; Export transformation

(defun lambda-expand-transform-child (fi name x)
  (with (fi-child (funinfo-get-child-funinfo fi)
	     lambda-expansion (lambda-embed-or-export fi-child
			   				  					  (lambda-body x)
			   				  					  t)
         free-vars  (funinfo-free-vars fi-child))
    (values `(%funref ,name (when free-vars
							  '%%lexical))
		    fi-exported
		    lambda-expansion)))

(defun lambda-export-transform (fi x)
  "Export and expand function."
  (with-gensym exported-fun
    (format t "Exporting ~A~%" exported-fun)
    (format t "In environment ~A~%" (funinfo-env fi))
    (format t "Environment args ~A~%" (funinfo-args fi))
	(with ((body fi-child lambda-expansion)
			 (lambda-expand-transform-child fi exported-fun x))
      (eval `(%set-atom-fun ,exported-fun
						    ,`#'(,(funinfo-args fi-child)
									,@lambda-expansion)))
	  body)))

;;; Export gathering

(defun lambda-export-gather-lexicals-from-child (fi exp-fi)
  (map (fn adjoin! _ (funinfo-lexicals fi))
	   (funinfo-free-vars exp-fi)))

(defun lambda-export-funinfo-link-to-child (fi fi-child)
  (funinfo-add-closure fi exp-fi)
  (lambda-export-gather-lexicals-from-child fi fi-child))

(defun lambda-expand-gather-child-make-funinfo (fi fi-child)
  (let args	(cons '%ghost (lambda-args x))
	 (make-funinfo :env (cons args
			  				  (copy-tree (funinfo-env fi)))
				   :args args
				   :parent-lexicals (funinfo-lexicals fi))))

; Do a gathering expansion to get the environment lists in place.
(defun lambda-expand-gather (fi name x)
  (let fi-child (lambda-expand-gather-child-make-funinfo fi)
    (lambda-embed-or-export fi-child
	  					    (lambda-body x)
			   				t)
	(lambda-export-funinfo-link-to-child fi fi-child)))

;;; Toplevel

(defun lambda-embed-or-export-branch (fi x export-lambdas)
  (if
    (lambda-call? x)
      (lambda-call-embed fi x export-lambdas)
    (and export-lambdas
		 (lambda? x))
      (lambda-export fi x)
	x))

(defun lambda-embed-or-export-tree (fi body export-lambdas)
  (tree-walk body
			 :ascending
			   (fn lambda-embed-or-export-branch fi _ export-lambdas)))

(defun lambda-embed-or-export (fi body export-lambdas)
  "Perform LAMBDA expansion on expression."
  ; Do an environment-gathering run.
  ;(format t "Top-level lambda gathering~%")
  ;(lambda-embed-or-export-tree fi body export-lambdas)
  ; Now just once again with appropriate funinfo.
  ;(format t "Top-level lambda expansion~%")
  (let body (lambda-embed-or-export-tree fi body export-lambdas)
    (vars-to-stackplaces fi
	    (if export-lambdas
	  		(make-lexical-body fi body)
			body))))

(defun lambda-expand (fun body &optional (parent-env nil) (export-lambdas t))
  "Perform LAMBDA expansion on function."
  (with (forms  (argument-expand-names 'lambda-expansion
									   (function-arguments fun))
         fi     (make-funinfo :env (cons forms parent-env)
							  :args forms))
    (values (lambda-embed-or-export fi body export-lambdas) fi)))
