;;;;; TRE environment
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun ignore-body-doc (body)
  (? (and (not *transpiler-assert*)
		  (string? body.)
		  .body)
	 .body
	 body))

(defvar *delayed-constructors* nil)

(defun transpiler_defclass (constructor-maker class-name args &rest body)
  (with (cname (? (cons? class-name)
				  (car class-name)
				  class-name)
		 bases (and (cons? class-name)
				    (cdr class-name))
		classes (transpiler-thisify-classes *current-transpiler*))
	(when *show-definitions*
	  (late-print `(defclass ,class-name ,@(awhen args (list !)))))
    (when (href classes cname)
	  (warn "Class ~A already defined." cname))
	(setf (href classes cname)
		  (? bases
    		 (with (bc (href classes (car bases)))
			   (make-class :members (class-members bc)
					       :parent bc));:methods (class-methods bc)))
			 (make-class)))
	(acons! cname
			(funcall constructor-maker cname bases args body)
		    *delayed-constructors*)
	nil))

(defun transpiler_defmethod (class-name name args &rest body)
  (let classes (transpiler-thisify-classes *current-transpiler*)
	(when *show-definitions*
      (late-print `(defmethod ,class-name ,name ,@(awhen args (list !)))))
    (aif (href classes class-name )
		 (let code (list args
				  	     (append (head-atoms body :but-last t)
							     (tail-after-atoms body :keep-last t)))
		   (? (assoc name (class-methods !))
              (progn
                (setf (assoc-value name (class-methods !)) code)
			    (warn "In class '~A': member '~A' already defined." class-name name))
		      (acons! name code (class-methods !))))
	    (error "Defiinition of method ~A: class ~A is not defined." name class-name)))
  nil)

(defun transpiler_defmember (class-name &rest names)
  (when *show-definitions*
    (late-print `(defmember ,class-name ,@names)))
  (let classes (transpiler-thisify-classes *current-transpiler*)
    (dolist (name names)
      (aif (href classes class-name)
           (push (list name t) (class-members !))
	       (error "Defiinition of member ~A: class ~A is not defined." name class-name)))))
