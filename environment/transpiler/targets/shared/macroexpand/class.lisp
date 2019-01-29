(var *delayed-constructors* nil)

(fn generic-defclass (constructor-maker class-name args &body body) ; TODO: Check if base classes are defined.
  (with (cname   (? (cons? class-name)
                    class-name.
                    class-name)
         bases   (& (cons? class-name)
                    .class-name)
         classes (thisify-classes))
    (print-definition `(defclass ,class-name ,@(!? args (list !))))
    (& (href classes cname)
       (warn "Class ~A already defined." cname))
    (& .bases
       (error "More than one base class but multiple inheritance is not supported."))
    (= (href classes cname)
       (? bases
          (alet (href classes bases.)
            (make-class :name    cname
                        :members (class-members !)
                        :parent  !))
          (make-class :name cname)))
    (acons! cname
            (funcall constructor-maker cname bases args body)
            *delayed-constructors*)
    nil))

(fn generic-defmethod (class-name name args &body body)
  (print-definition `(defmethod ,class-name ,name ,@(!? args (list !))))
  (!? (href (thisify-classes) class-name)
      (let code (list args body)
        (? (assoc name (class-methods !))
           {(= (assoc-value name (class-methods !)) code)
            (warn "In class '~A': member '~A' already defined." class-name name)}
           (acons! name code (class-methods !))))
      (error "Cannot define method ~A for undefined class ~A." name class-name))
  nil)

(fn generic-defmember (class-name &rest names)
  (print-definition `(defmember ,class-name ,@names))
  (!? (href (thisify-classes) class-name)
      (+! (class-members !) (@ [list _ t] names))
      (error "Class ~A is not defined." class-name))
  nil)
