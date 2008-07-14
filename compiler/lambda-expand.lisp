;;;;; nix operating system project
;;;;; lisp compiler
;;;;; Copyright (C) 2005-2007 Sven Klose <pixel@copei.de>
;;;;;
;;;;; LAMBDA expansion.
;;;;;
;;;;; This pass embeds or exports functions from functions and allocates
;;;;; stack slots for arguments and free-variable bindings, to enable the
;;;;; following expression expansion.
;;;;;
;;;;; Expressions of the following form are inlined:
;;;;;
;;;;;   ((#'lambda (x) x) y)
;;;;;
;;;;; Functions with free variables are exported:
;;;;;
;;;;;   #'(lambda (x) y)
;;;;;
;;;;; Executed unnamed toplevel functions don't a stack but a resident
;;;;; memory block is allocated.

(defmacro with-lambda-call ((args vals body call) &rest exec-body)
  "Bind local function call components to variables for exec-body."
  (with-gensym (tmp l)
    `(let* ((,tmp ,call)
                    (,l (second (car ,tmp)))
            (,args (lambda-args ,l))
            (,vals (lambda-call-vals ,tmp))
            (,body (lambda-body ,l)))
       ,@exec-body)))

;;; Stack setup
;;;
;;; Stack operations should be created in the ssa pass.

(defun make-stackop (var fi)
  "Make stack operation. If the variable is not in the current environment,
   it is returned as is and added to the free-variable list of the funinfo."
  (aif (funinfo-env-pos fi var)
    `(%stack ,!)
    `(%vec (%stack 0) ,(or (funinfo-free-var-pos fi var)
                           (progn
                             (funinfo-add-free-var fi var)
                             (funinfo-free-var-pos fi var))))))

(defun is-stackvar? (var fi)
  "Check if a variable is on the stack."
  (and (atom var)
    (dolist (sl (funinfo-env fi))
      (when (and sl (find var sl))
        (return t)))))

(defun vars-to-stackops (body fi)
  "Replaces variables by stack operations. Returns modified body.
   Free variables are added to free-vars of the funinfo."
  (tree-walk body
    :ascending
      #'((e)
         (if (is-stackvar? e fi)
             (make-stackop e fi)
			 e))))

;;; LAMBDA inlining

(defun make-inline-body (args vals body)
  "Make body with stack variable initialisers."
  `(vm-scope
	 ,@(mapcar #'((a v)
				  `(%setq ,a ,v))
			   args vals)
     ,@body))

(defun lambda-call-embed (lambda-call fi export-lambdas)
  "Replace local LAMBDA expression by its body using stack variables."
  (with-lambda-call (args vals body lambda-call)
    (with ((a v) (assoc-splice (argument-expand args vals t)))
      (with-funinfo-env-temporary fi args
        (make-inline-body
			a
      		(vars-to-stackops v fi)
			(lambda-embed-or-export body fi export-lambdas))))))

;;; LAMBDA export

(defun make-varblock-inits (fi fv)
  (mapcar #'((v) `(%set-vec ,s ,(position v fv) ,(make-stackop v fi))) fv))

(defun make-varblock-exits (fi fv)
  (mapcar #'((v) `(%get-vec ,s ,(make-stackop v fi) ,(position v fv))) fv))

(defun make-call-to-exported (name fi)
  (with (f	    (symbol-function name)
		 exp-fi	(atomic-expand-lambda f (function-body f) (funinfo-env-this fi))
         fv     (queue-list (funinfo-free-vars exp-fi)))
    (if fv
        (with-gensym g
		  ; XXX move past SSA.
          (funinfo-env-add-args fi (list g))
          (with (s (make-stackop g fi))
            `(vm-scope
               (%setq ,s (make-array ,(length fv)))
			   ,@(make-varblock-inits fi fv)
               (%funref ,name ,s)
			   ,@(make-varblock-exits fi fv))))
		`(%funref ,name nil))))

(defun lambda-export (x fi)
  "Export and expand LAMBDA expression out of a function."
  (with-gensym g
    (eval `(%set-atom-fun ,g ,x)) ; Create new function.
    (make-call-to-exported g fi)))

;;; Toplevel

(defun lambda-embed-or-export (body fi export-lambdas)
  "Merge LAMBDA expressions and replace variables by stack operations."
  (vars-to-stackops
      (tree-walk body
      	  :ascending
        	  #'((x)
             	 (if (is-lambda-call? x)
                 	 (lambda-call-embed x fi export-lambdas)
                 	 (if (and export-lambdas
							  (is-lambda? x))
                   	  	 (lambda-export x fi)
				   	  	 x))))
	  fi))

(defun lambda-expand (fun body &optional (parent-env nil) (export-lambdas t))
  "Convert native function to stack function."
  (with (forms  (argument-expand (function-arguments fun) nil nil)
         fi     (make-funinfo :env (list forms parent-env)))
    (values (lambda-embed-or-export body fi export-lambdas) fi)))
