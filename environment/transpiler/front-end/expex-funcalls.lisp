;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defvar *compiled-apply* (compiled-function-name 'apply))

(defun %setq-make-call-to-local-function (x f)
  `(%setq ,(second x)
		  (,*compiled-apply* (cons ,f
								   (cons ,(compiled-list (cdr (third x)))
							 			 nil)))))

(defun %setq-make-immediate-function-call (x)
  (let expr (%setq-value x)
    `(%setq ,(%setq-place x)
			(,(compiled-function-name expr.) ,@.expr))))

(defun expex-local-funcall (x)
  (if (%setq-value-atom? x)
	  x
      (let fun (first (%setq-value x))
	    (if (or (consp fun)
		        (expex-in-env? fun))
  	        (%setq-make-call-to-local-function x fun)
	        x))))

(defun expex-compiled-funcall (x)
  "To be called by expex: APPLY calls to local functions and make
   immediate global function calls."
  (if (%setq-value-atom? x)
	    x
      (let fun (first (%setq-value x))
	    (if
		  (or (consp fun)
		      (expex-in-env? fun))
  	        (%setq-make-call-to-local-function x fun)
      	  (transpiler-defined-function *current-transpiler* (first (%setq-value x)))
	    	(%setq-make-immediate-function-call x)
			x))))
