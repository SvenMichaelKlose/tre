;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>
;;;;;
;;;;; Wrap local method calls into SLOT-VALUEs.

(defun thisify-collect-methods-and-members (clsdesc)
  (append (class-methods clsdesc)
		  (class-members clsdesc)
		  (awhen (class-parent clsdesc)
			(thisify-collect-methods-and-members !))))

(defun thisify-symbol (classdef x exclusions)
  (!? (& classdef
         (not (| (number? x) (string? x)))
         (not (member x exclusions :test #'eq))
         (assoc x classdef))
      `(%slot-value ~%this ,x)
      x))

(defun thisify-list-0 (classdef x exclusions)
  (?
	(atom x)    (thisify-symbol classdef x exclusions)
	(%quote? x) x
	(lambda? x) (copy-lambda x :body (thisify-list-0 classdef (lambda-body x) (append exclusions (lambda-args x))))
    (progn
      (make-default-listprop x)
      (cons (? (%slot-value? x.)
			   `(%slot-value ,(thisify-list-0 classdef (cadr x.) exclusions)
					         ,(caddr x.))
			   (thisify-list-0 classdef x. exclusions))
		    (thisify-list-0 classdef .x exclusions)))))

(defun thisify-list (classes x cls)
  (thisify-list-0 (thisify-collect-methods-and-members (href classes cls)) x nil))

(def-head-predicate %thisify)

(defun thisify (classes x)
  (?
	 (atom x)       x
	 (%thisify? x.) (append (thisify-list classes (cddr x.) (cadr x.))
			                (thisify classes .x))
     (progn
       (make-default-listprop x)
	   (cons (thisify classes x.)
	 	     (thisify classes .x)))))
