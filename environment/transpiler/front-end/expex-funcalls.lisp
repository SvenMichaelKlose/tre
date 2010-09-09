;;;;; TRE transpiler
;;;;; Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>

(defun %setq-make-call-to-local-function (x f)
  `(%setq ,(second x)
		  (compiled_apply
			   (cons ,f
					 (cons ,(compiled-list (cdr (third x)))
						   nil)))))

(defun expex-compiled-funcall (x)
  (if (%setq-value-atom? x)
	  x
      (let fun (first (%setq-value x))
	    (if
		  (consp fun)
  	        (%setq-make-call-to-local-function x fun)
		  (expex-in-env? fun)
  	        (%setq-make-call-to-local-function x fun)
	  	  x))))
