; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@copei.de>

(defvar *delayed-constructors* nil)

(defun generic-defclass (constructor-maker class-name args &body body)
  (with (cname  (? (cons? class-name) class-name. class-name)
		 bases  (& (cons? class-name) .class-name)
		 classes (thisify-classes))
	(print-definition `(defclass ,class-name ,@(awhen args (list !))))
    (& (href classes cname)
	   (warn "Class ~A already defined." cname))
    (& .bases
       (error "More than one base class but multiple inheritance is not supported."))
	(= (href classes cname)
       (? bases
          (let bc (href classes bases.)
            (make-class :name    class-name
                        :members (class-members bc)
                        :parent  bc))
          (make-class)))
	(acons! cname
			(funcall constructor-maker cname bases args body)
		    *delayed-constructors*)
	nil))

(defun generic-defmethod (class-name name args &body body)
  (print-definition `(defmethod ,class-name ,name ,@(awhen args (list !))))
  (!? (href (thisify-classes) class-name)
      (let code (list args body)
        (? (assoc name (class-methods !))
           (progn
             (= (assoc-value name (class-methods !)) code)
             (warn "In class '~A': member '~A' already defined."
                   class-name name))
           (acons! name code (class-methods !))))
      (error "Definition of method ~A: class ~A is not defined."
             name class-name))  ; TODO: Fix. Isn't called.
  nil)

(defun generic-defmember (class-name &rest names)
  (print-definition `(defmember ,class-name ,@names))
  (!? (href (thisify-classes) class-name)
      (append! (class-members !) (@ [list _ t] names))
      (error "Class ~A is not defined." class-name))
  nil)
