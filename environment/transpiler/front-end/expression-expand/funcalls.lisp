;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defun %setq-make-call-to-local-function (x)
  (with-%setq place value x
    (expex-body *current-expex* (transpiler-frontend-1 *current-transpiler* `((%setq ,place (apply ,value. ,(compiled-list .value))))))))

(defun expex-compiled-funcall (x)
  (? (%setq-value-atom? x)
	 (list x)
     (alet (car (%setq-value x))
	   (?
	     (function-expr? !) (%setq-make-call-to-local-function x)
		 (expex-in-env? !) (%setq-make-call-to-local-function x)
	  	 (list x)))))
