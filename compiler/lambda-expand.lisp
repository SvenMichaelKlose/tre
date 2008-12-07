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

(defun is-env-var? (var fi locals)
  "Check if symbol is a varable in the current environment."
  (and (atom var)
       (dolist (stack-places (funinfo-env fi))
         (when (and stack-places
				    (find var stack-places)
				    (not (find var locals)))
           (return t)))))

(defun vars-to-stackplaces (body fi &optional (locals nil))
  "Replaces variables by stack operations. Returns modified body.
   Free variables are added to free-vars of the funinfo."
  (tree-walk body
	:dont-ascend-after-if
	  (fn (or (%slot-value? _)
			  (lambda? _)))
    :ascending
      (fn (if (lambda? _) ; Add variables to ignore in subfunctions.
			  (vars-to-stackplaces _ fi (append locals
												(lambda-args-expanded _)))
			  (if (%slot-value? _)
				  `(%slot-value ,(vars-to-stackplaces (second _) fi) ,(third _))
           	      (if (is-env-var? _ fi locals)
               	      (make-stackplace fi _)
			   	      _))))))

;;; LAMBDA inlining

(defun make-inline-body (stack-places values body)
  "Make body with stack variable initialisers."
  `(vm-scope
	 ,@(mapcan #'((stack-place init-value)
				  `((%var ,stack-place)
					(%setq ,stack-place ,init-value)))
			   stack-places values)
     ,@body))

(defun lambda-call-embed (lambda-call fi export-lambdas)
  "Replace local LAMBDA expression by its body using stack variables."
  (with-lambda-call (args vals body lambda-call)
    (with ((a v) (assoc-splice (argument-expand 'local-var-fun args vals t)))
      (with-funinfo-env-temporary fi args
        (make-inline-body
			(vars-to-stackplaces a fi)
      		v
			(lambda-embed-or-export body fi export-lambdas))))))

;;; LAMBDA export

(defun make-varblock-inits (s fi free-vars)
  (mapcar (fn `(%set-vec ,s
						 ,(position _ free-vars)
						 ,(make-stackplace fi _)))
		  free-vars))

(defun make-call-to-exported (name fi)
  (with (f  (symbol-function name)
		 ; Expand exported function to get its free variables.
		 fi-exported  (atomic-expand-lambda
					    f
					    (function-body f)
					    (funinfo-env-this fi))
         free-vars  (queue-list (funinfo-free-vars fi-exported)))
    (if free-vars
        (with-gensym free-vars-vec-argument
          (funinfo-env-add-arg fi free-vars-vec-argument)
          (with (free-vars-vec (make-stackplace fi free-vars-vec-argument))
            `(vm-scope
               (%setq ,free-vars-vec (make-array ,(length free-vars)))
			   ,@(make-varblock-inits free-vars-vec fi free-vars)
               (%funref ,name ,free-vars-vec))))
		; Function reference without free variables.
		`(%funref ,name nil))))

(defun lambda-export (x fi)
  "Export and expand function."
  (with-gensym g
    (eval `(%set-atom-fun ,g ,x)) ; Create new function.
    (make-call-to-exported g fi)))

;;; Toplevel

(defun lambda-embed-or-export (body fi export-lambdas)
  "Perform LAMBDA expansion on expression."
  (vars-to-stackplaces ; Convert function arguments to stackplaces.
    (tree-walk body
      :ascending
         (fn (if (lambda-call? _)
                 (lambda-call-embed _ fi export-lambdas)
                 (if (and export-lambdas
						  (lambda? _))
                   	 (lambda-export _ fi)
				   	 _))))
	  fi))

(defun lambda-expand (fun body &optional (parent-env nil) (export-lambdas t))
  "Perform LAMBDA expansion on function."
  (with (forms  (argument-expand-names 'lambda-expansion
									   (function-arguments fun))
         fi     (make-funinfo :env (list forms parent-env)))
    (values (lambda-embed-or-export body fi export-lambdas) fi)))
