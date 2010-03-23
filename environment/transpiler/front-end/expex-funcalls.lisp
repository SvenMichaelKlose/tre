;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defvar *compiled-apply* (compiled-function-name 'apply))

(defun %setq-make-call-to-local-function (x f)
  `(%setq ,(second x)
		  (,*compiled-apply* (cons ,f
								   (cons ,(compiled-list (cdr (third x)))
							 			 nil)))))

(defun %setq-make-immediate-function-call (x f)
  (let expr (%setq-value x)
    `(%setq ,(%setq-place x)
			(,(compiled-function-name f) ,@.expr))))

(defun expex-compiled-funcall (x)
  "To be called by expex: APPLY calls to local functions and make
   immediate global function calls."
  (if (%setq-value-atom? x)
	  x
      (let fun (first (%setq-value x))
	    (if
		  (function-ref-expr? fun)
      	    (if
			  (expex-in-env? .fun.)
  	        	(%setq-make-call-to-local-function x .fun.)
		      (%setq-make-immediate-function-call x .fun.))
		  (consp fun)
  	        (%setq-make-call-to-local-function x fun)
		  (expex-in-env? fun)
  	        (%setq-make-call-to-local-function x fun)
      	  (transpiler-defined-function *current-transpiler* fun)
		    (%setq-make-immediate-function-call x fun)
	  	  x))))
