;;;; list processor
;;;; Copyright (c) 2007 Sven Klose <pixel@copei.de>

(defun remove-if (fun x)
  (when x
    (if (not (funcall fun (car x)))
      (cons (car x) (remove-if fun (cdr x)))
      (remove-if fun (cdr x)))))
