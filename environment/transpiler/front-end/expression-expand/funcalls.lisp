;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defun %setq-make-call-to-local-function (x f)
  (expex-body *current-expex*
              `((%setq ,(cadr x)
		               (,(compiled-user-function-name 'apply)
			               (cons ,f
					             (cons ,(compiled-list (cdr (caddr x)))
						               nil)))))))

(defun expex-compiled-funcall (x)
  (? (%setq-value-atom? x)
	 (list x)
     (let fun (car (%setq-value x))
	   (?
	     (function-expr? fun) (%setq-make-call-to-local-function x fun)
		 (expex-in-env? fun) (%setq-make-call-to-local-function x fun)
	  	 (list x)))))
