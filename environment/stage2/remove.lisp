;;;; TRE environment
;;;; Copyright (c) 2007-2008 Sven Klose <pixel@copei.de>

(defun remove-if (fun x)
  (when x
    (if (funcall fun (car x))
        (remove-if fun (cdr x))
        (cons (car x)
			  (remove-if fun (cdr x))))))

(defun remove-if-not (fun x)
  (remove-if (fn not (funcall fun _))
			 x))

(defun remove (elm x &optional (test #'eq))
  (remove-if (fn funcall test elm _)
			 x))
