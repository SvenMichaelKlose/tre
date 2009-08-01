;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun transpiler-make-named-functions (tr x)
  (with (rec #'((x)
          (when x
	        (if (and (%setq? x.)
	                  (lambda? (third x.)))
	            (cons `(function ,(second (second x)) ,(second (third x.)))
		              (rec (cdddr x)))
	            (cons x.
		              (rec .x))))))
	(if (transpiler-named-functions? tr)
		(rec x)
		x)))
