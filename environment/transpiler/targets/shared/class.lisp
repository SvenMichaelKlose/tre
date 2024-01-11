(fn generic-defclass (constructor-maker class-name args body)
  (print-definition `(defclass ,class-name ,@(!? args (list !))))
  (with (cname    (? (cons? class-name) class-name. class-name)
         bases    (& (cons? class-name) .class-name)
         classes  (defined-classes))
    (& (href classes cname)
       (error "Class ~A already defined." cname))
    (& .bases
       (error "Multiple inheritance is not supported."))
    (& bases
       (not (href classes bases.))
       (error "Undefined base class ~A." bases.))
    (= (href classes cname)
       (make-class :name     cname
                   :base     bases.
                   :members  (& bases (class-members (href classes bases.)))
                   :parent   (& bases (href classes bases.))
                   :constructor-maker
                     (list constructor-maker args body)))
    nil))

(fn generic-defmethod (class-name name args body)
  (print-definition `(defmethod ,class-name ,name ,@(!? args (list !))))
  (!? (href (defined-classes) class-name)
      (let code (list args body)
        (? (assoc name (class-methods !))
           (progn
             (warn "In class '~A': member '~A' already defined."
                   class-name name)
             (= (assoc-value name (class-methods !)) code))
           (acons! name code (class-methods !))))
      (error "Undefined class ~A." name class-name))
  nil)

(fn generic-defmember (class-name names)
  (print-definition `(defmember ,class-name ,@names))
  (!? (href (defined-classes) class-name)
      (+! (class-members !) (@ [list _ t] names))
      (error "Undefined lass ~A." class-name))
  nil)
