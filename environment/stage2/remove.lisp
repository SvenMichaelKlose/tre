;;;; list processor
;;;; Copyright (c) 2007-2008 Sven Klose <pixel@copei.de>

(defun remove-if (fun x)
  (when x
    (if (funcall fun (car x))
      (remove-if fun (cdr x))
      (cons (car x) (remove-if fun (cdr x))))))

(defun remove (elm lst &optional (test #'eq))
  (remove-if #'((x)
				  (funcall test elm x))
			 lst))
