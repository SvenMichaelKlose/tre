;;;;; TRE environment
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Classes

(defun ignore-body-doc (body)
  (? (and (not *transpiler-assert*)
		  (string? body.)
		  .body)
	 .body
	 body))

(defvar *delayed-constructors* nil)

(defun transpiler_defclass (constructor-maker class-name args &rest body)
  (with (cname (? (cons? class-name)
				  (first class-name)
				  class-name)
		 bases (and (cons? class-name)
				    (cdr class-name))
		classes (transpiler-thisify-classes *current-transpiler*))
	(when *show-definitions*
	  (late-print `(defclass ,class-name ,@(awhen args (list !)))))
    (when (href classes cname)
	  (error "Class ~A already defined." cname))
	(setf (href classes cname)
		  (? bases
    		 (with (bc (href classes (first bases)))
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
		 (? (assoc name (class-methods !))
			(error "In class '~A': member '~A' already defined." class-name name)
            (setf (class-methods !)
		          (push (list name args
						  	  (append (head-atoms body :but-last t)
									  (when (transpiler-inject-function-names?  *current-transpiler*)
										`((setf *current-function*
											    ,(+ (symbol-name class-name)
												    "."
													(symbol-name name)))))
									  (tail-after-atoms body :keep-last t)))
					    (class-methods !))))
	    (error "Defiinition of method ~A: class ~A is not defined."
			   name class-name)))
  nil)

(defun transpiler_defmember (class-name &rest names)
  (when *show-definitions*
    (late-print `(defmember ,class-name ,@names)))
  (let classes (transpiler-thisify-classes *current-transpiler*)
    (dolist (name names)
      (aif (href classes class-name)
           (setf (class-members !)
		         (push (list name t)
				       (class-members !)))
	      (error "Defiinition of member ~A: class ~A is not defined."
			     name class-name)))))
