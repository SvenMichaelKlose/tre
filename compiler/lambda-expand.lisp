;;;;; TRE compiler
;;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>
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
       `(%vec (%stack 0) ,(or (funinfo-free-var-pos fi var)
                              (progn
                                (funinfo-add-free-var fi var)
                                (funinfo-free-var-pos fi var))))))

(defun is-env-var? (fi var)
  "Check if symbol is a varable in the current environment."
  (when (atom var)
    (find var (apply #'append (funinfo-env fi)))))

(defun vars-to-stackplaces (fi body)
  "Replaces variables by stack operations. Returns modified body.
   Free variables are added to free-vars of the funinfo."
  (tree-walk body
	:dont-ascend-after-if
	  (fn (or (%slot-value? _)
			  (lambda? _)))
    :ascending
      (fn (cond
		    ((lambda? _) ; Add variables to ignore in subfunctions.
			   (vars-to-stackplaces fi _ ))
			((%slot-value? _)
			   `(%slot-value ,(vars-to-stackplaces fi (second _)) ,(third _)))
           	((is-env-var? fi _)
               (make-stackplace fi _))
			(t _)))))

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

(defun make-varblock-inits (fi s free-vars)
  (mapcar (fn `(%set-vec ,s
						 ,(position _ free-vars)
						 ,(make-stackplace fi _)))
		  free-vars))

(defun make-call-to-exported (fi name)
  (with (exported-name  (symbol-function name)
		 ; Expand exported function to get its free variables.
		 fi-exported  (atomic-expand-lambda
					    exported-name
					    (funinfo-env-this fi))
         free-vars  (reverse (funinfo-free-vars fi-exported)))
    (if free-vars
        (with-gensym free-vars-vec-argument
          (funinfo-env-add-arg fi free-vars-vec-argument)
          (with (free-vars-vec (make-stackplace fi free-vars-vec-argument))
            `(vm-scope
               (%setq ,free-vars-vec (make-array ,(length free-vars)))
			   ,@(make-varblock-inits fi free-vars-vec free-vars)
               (%funref ,name ,free-vars-vec))))
		; Function reference without free variables.
		`(%funref ,name nil))))

(defun lambda-export (fi x)
  "Export and expand function."
  (with-gensym exported-fun
    (eval `(%set-atom-fun ,exported-fun ,x)) ; Create new function.
    (make-call-to-exported fi exported-fun)))

;;; Toplevel

(defun lambda-embed-or-export (fi body export-lambdas)
  "Perform LAMBDA expansion on expression."
  (vars-to-stackplaces ; Convert function arguments to stackplaces.
	fi
    (tree-walk body
      :ascending
         (fn (cond
			   ((lambda-call? _)
                  (lambda-call-embed fi _ export-lambdas))
               ((and export-lambdas
					 (lambda? _))
                  (lambda-export fi _))
			   (t _))))))

(defun lambda-expand (fun body &optional (parent-env nil) (export-lambdas t))
  "Perform LAMBDA expansion on function."
  (with (forms  (argument-expand-names 'lambda-expansion
									   (function-arguments fun))
         fi     (make-funinfo :env (list forms parent-env)))
    (values (lambda-embed-or-export fi body export-lambdas) fi)))
