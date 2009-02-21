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

(defun make-stackplace (fi var)
  (if (funinfo-arg? fi var)
	  var
  (aif (funinfo-env-pos fi var)
       `(%stack ,!)
       `(%vec %ghost ,(or (funinfo-free-var-pos fi var)
                          (progn
                            (funinfo-add-free-var fi var)
                            (funinfo-free-var-pos fi var)))))))

(defun is-env-var? (fi var)
  (when (and (atom var)
			 (not (member var (funinfo-args fi))))
    (member var (apply #'append (funinfo-env fi)))))

(defun make-lexical-place (fi var)
  (if (or (not var)
		  (consp var)
		  (eq '%%lexical var))
	  var
  	  (aif (funinfo-lexical-pos fi var)
	       `(aref %%lexical ,!)
	       var)))

(defun vars-to-stackplaces-atom (fi x)
  (if
    (lambda? x) ; Add variables to ignore in subfunctions.
	  `#'(,(lambda-args x)
			 ,@(vars-to-stackplaces fi (lambda-body x)))
	(%slot-value? x)
	  `(%slot-value ,(vars-to-stackplaces fi (second x)) ,(third x))
   	(is-env-var? fi x)
   	  (make-stackplace fi x)
	x))

(defun vars-to-stackplaces (fi body)
  (tree-walk body
	:dont-ascend-after-if
	  (fn (or (%slot-value? _)
			  (lambda? _)))
    :ascending
      (fn vars-to-stackplaces-atom fi (make-lexical-place fi _))))

;;; LAMBDA inlining

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

(defun print-funinfo (fi)
  (format t "Arguments ~A~%" (funinfo-args fi))
  (format t "Lexicals: ~A~%" (funinfo-lexicals fi))
  (format t "Free vars: ~A~%" (funinfo-free-vars fi))
  (format t "Env ~A~%" (funinfo-env fi))
  fi)

;;; Export

(defun make-env-inits (fi)
  (mapcan (fn (unless (or (funinfo-arg? fi _)
						  (funinfo-lexical-pos fi _))
				`((%var ,_))))
	      (funinfo-env-this fi)))

(defun make-varblock-inits (fi)
  (let lexicals (funinfo-lexicals fi)
    (mapcan (fn (when (funinfo-lexical-pos fi _)
				  `((%%usetf-aref ,_
							      %%lexical
						 	      ,(position _ lexicals)))))
		    (funinfo-args fi))))

(defun make-lexical-inits (fi body)
  (let lexicals (funinfo-lexicals fi)
    (format t "Lexical scope with ~A entries.~%" (length lexicals))
    `(,@(when (atom body.)
	      (list body.))
	  ,@(make-env-inits fi)
	  ,@(when lexicals
          `((%setq %%lexical
	               (make-array ,(length lexicals)))
   	  ,@(make-varblock-inits fi)))
      ,@(if (atom body.)
		    .body
		    body))))

(defun lambda-export-make-exported (fi fi-child x)
  (with-gensym name
    (format t "Exporting ~A with args ~A~%" name (funinfo-args fi-child))
    (eval `(%set-atom-fun ,name
						  ,`#'(,(funinfo-args fi-child)
								  ,@(lambda-body x))))
	(funinfo-add-closure fi name fi-child)
	name))

(defun lambda-export-transform (fi x)
  (let fi-child (funinfo-get-child-funinfo fi)
    `(%funref ,(lambda-export-make-exported fi fi-child x)
			  ,(when (funinfo-free-vars fi-child)
				 '%%lexical))))

;;; Export gathering

(defun lambda-export-gather-lexicals-from-child (fi fi-child)
  (map (fn (if (funinfo-env-pos fi _)
		       (funinfo-add-lexical fi _)
		       (funinfo-add-free-var fi _)))
	   (funinfo-free-vars fi-child))
  (when (funinfo-free-vars fi-child)
    (funinfo-env-add fi '%%lexical)))

(defun lambda-export-funinfo-link-to-child (fi fi-child)
  (format t "Gathered closure info.~%")
  (funinfo-add-gathered-closure-info fi fi-child)
  (lambda-export-gather-lexicals-from-child fi fi-child))

(defun lambda-export-gather-child-make-funinfo (fi)
  (let args	(cons '%ghost (lambda-args x))
	 (make-funinfo :env (cons args
			  				  (copy-tree (funinfo-env fi)))
				   :args args
				   :parent-lexicals (funinfo-lexicals fi))))

;; Do a gathering expansion to initialize FUNINFO tree which
;; reflects the structure of a function and all functions
;; created in it.
(defun lambda-export-gather (fi x)
  (let fi-child (lambda-export-gather-child-make-funinfo fi)
    (lambda-expand-gather fi-child
	  				      (lambda-body x)
			   			  t)
	(lambda-export-funinfo-link-to-child fi fi-child))
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

;; XXX (defun lambda-expand-0 (fi body export-lambdas)
(defun lambda-embed-or-export (fi body export-lambdas)
  (when export-lambdas
    (lambda-expand-tree fi body export-lambdas t))
  (vars-to-stackplaces fi
     (make-lexical-inits fi
         (lambda-expand-transform fi body export-lambdas))))

(defun lambda-expand (fun body &optional (parent-env nil) (export-lambdas t))
  (with (forms  (argument-expand-names 'lambda-expansion
									   (function-arguments fun))
         fi     (make-funinfo :env (cons forms parent-env)
							  :args forms))
    (values (lambda-embed-or-export fi body export-lambdas) fi)))
