(macro with-defined-class (cls class-name &body body)
  `(let-if ,cls (href (defined-classes) ,class-name)
     (progn ,@body)
     (error "Undefined class ~A." ,class-name)))

(fn generic-defclass (constructor-maker class-name args body)
  (print-definition `(defclass ,class-name ,@(!? args (… !))))
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
    (= (href classes cname) (make-class :name   cname
                                        :base   bases.
                                        :parent (& bases (href classes bases.))
                                        :constructor-maker
                                          (… constructor-maker args body)))
    nil))

(fn access-type? (x)
  (in? x :static :protected :private))

(fn get-method-flags-and-rest (x)
  (with (r #'((x flags)
               (? (access-type? x.)
                  (? (member x. flags)
                     (error "Double method flag ~A." x.)
                     (r .x (. x. flags)))
                  (values x flags))))
    (r x nil)))

(fn assert-slot-undefined (cls name)
  (& (class-slot? cls name)
     (error "In class '~A': slot '~A' already defined." (class-name cls) name)))

(fn generic-defmethod (x)
  (with ((args flags) (get-method-flags-and-rest x))
    (*> #'((class-name name args body)
            (print-definition `(defmethod ,class-name ,name ,args))
            (with-defined-class ! class-name
              (assert-slot-undefined ! name)
              (push (make-%slot :type :method :flags flags
                                :name name :args args :body body)
                    (class-slots !))))
          (argument-expand-values 'defmethod '(class-name name args &body body)
                                  args)))
  nil)

(fn generic-defmember (class-name names)
  (print-definition `(defmember ,class-name ,@names))
  (with-defined-class cls class-name
    (+! (class-slots cls)
        (@ [with ((args flags) (get-method-flags-and-rest (ensure-list _)))
             (assert-slot-undefined cls args.)
             (make-%slot :type :member :flags flags
                         :name args. :body .args)]
           names)))
  nil)
