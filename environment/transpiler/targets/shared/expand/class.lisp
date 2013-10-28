;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *delayed-constructors* nil)

(defun transpiler_defclass (constructor-maker class-name args &rest body)
  (with (cname (? (cons? class-name) class-name. class-name)
		 bases (& (cons? class-name) .class-name)
		 classes (transpiler-thisify-classes *transpiler*))
	(print-definition `(defclass ,class-name ,@(awhen args (list !))))
    (& (href classes cname)
	   (warn "Class ~A already defined." cname))
	(= (href classes cname)
      (? bases
         (let bc (href classes bases.)
           (make-class :members (class-members bc)
                       :parent bc));:methods (class-methods bc)))
         (make-class)))
	(acons! cname
			(funcall constructor-maker cname bases args body)
		    *delayed-constructors*)
	nil))

(defun transpiler_defmethod (class-name name args &rest body)
  (print-definition `(defmethod ,class-name ,name ,@(awhen args (list !))))
  (!? (href (transpiler-thisify-classes *transpiler*) class-name)
      (let code (list args (append (head-if #'atom body :but-last t)
                                   (tail-after-atoms body :keep-last t)))
        (? (assoc name (class-methods !))
           (progn
             (= (assoc-value name (class-methods !)) code)
             (warn "In class '~A': member '~A' already defined." class-name name))
           (acons! name code (class-methods !))))
      (error "Defiinition of method ~A: class ~A is not defined." name class-name))
  nil)

(defun transpiler_defmember (class-name &rest names)
  (print-definition `(defmember ,class-name ,@names))
  (!? (href (transpiler-thisify-classes *transpiler*) class-name)
      (append! (class-members !) (mapcar [list _ t] names))
      (error "Class ~A is not defined." class-name))
  nil)
