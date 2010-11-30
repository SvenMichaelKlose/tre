;;;;; TRE transpiler
;;;;; Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>

(defun %setq-make-call-to-local-function (x f)
  (expex-body *current-expex*
              `((%setq ,(cadr x)
		               (userfun_apply
			               (cons ,f
					             (cons ,(compiled-list (cdr (third x)))
						               nil)))))))

(defun expex-compiled-funcall (x)
  (if (%setq-value-atom? x)
	  (list x)
      (let fun (car (%setq-value x))
	    (if
		  (function-expr? fun)
  	        (%setq-make-call-to-local-function x fun)
		  (expex-in-env? fun)
  	        (%setq-make-call-to-local-function x fun)
	  	  (list x)))))
