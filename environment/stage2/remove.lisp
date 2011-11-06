;;;; tré - Copyright (c) 2007-2009,2011 Sven Klose <pixel@copei.de>

(functional remove remove-if remove-if-not)

(defun remove-if (fun x)
  (?
    (not x) nil
    (funcall fun (car x)) (remove-if fun (cdr x))
    (cons (car x)
	      (remove-if fun (cdr x)))))

(defun remove-if-not (fun x)
  (remove-if (fn not (funcall fun _))
			 x))

(defun remove (elm x &key (test #'eql))
  (remove-if (fn funcall test elm _)
			 x))
