;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun traverse (fun x &rest args)
  (cons (apply fun (cons (car x) args))
	    (apply fun (cons (cdr x) args))))

(defun traverse-cdr (fun x &rest args)
  (cons (car x)
	    (apply fun (cons (cdr x) args))))

; XXX tests missing
