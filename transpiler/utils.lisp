;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Utilities
;;;;;
;;;;; This code should be moved to the environment.

(defun tree-list (x)
  (if (atom x)
	  x
      (if (consp (car x))
	      (nconc (tree-list (car x))
			     (tree-list (cdr x)))
	      (cons (car x)
			    (tree-list (cdr x))))))

(defun mapatree (fun x)
  (if (atom x)
      (if x
	  	  (funcall fun x)
		  x)
	  (cons (mapatree fun (car x))
			(mapatree fun (cdr x)))))

(defun maptree (fun tree)
  (if (atom tree)
      (funcall fun tree)
      (mapcar #'((x)
                  (if (consp x)
                      (funcall fun (maptree fun (funcall fun x)))
                      (funcall fun x)))
              tree)))

(defun transpiler-concat-string-tree (x)
  (apply #'string-concat (tree-list x)))
