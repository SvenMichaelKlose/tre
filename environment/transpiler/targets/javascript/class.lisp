(defun js-gen-inherit-methods (class-name base-name)
  `(,@(!? base-name
          `((= (slot-value ,(compiled-function-name class-name) 'prototype) (*object.create (slot-value ,! 'prototype)))))
    (= (slot-value (slot-value ,(compiled-function-name class-name) 'prototype) 'constructor) ,class-name)))

(defun js-gen-inherit-constructor-calls (bases)
  (@ [`((slot-value ,_ 'CALL) this)]
     bases))

(defun js-gen-constructor (class-name bases args body)
  (let magic (list 'quote ($ '__ class-name))
    `{(defun ,class-name ,args
        (%thisify ,class-name
          (macrolet ((super (&rest args)
                       `((slot-value ,bases. 'call) this ,@args)))
            ,@body)))
	  (defun ,($ class-name '?) (x)
	    (%%native x " instanceof " ,(compiled-function-name-string class-name)))}))

(define-js-std-macro defclass (class-name args &body body)
  (apply #'generic-defclass #'js-gen-constructor class-name args body))

(define-js-std-macro defmethod (class-name name args &body body)
  (apply #'generic-defmethod class-name name args body))

(define-js-std-macro defmember (class-name &rest names)
  (apply #'generic-defmember class-name names))

(defun js-emit-method (class-name x)
  (alet ($ '~meth- class-name '- x.)
    (. `((%%native ,x.) #',!)
	   `(defun ,! ,.x.
		  (%thisify ,class-name
	        ,@(| ..x. (list nil)))))))

(defun js-emit-methods (class-name cls)
  (awhen (@ [js-emit-method class-name _]
            (reverse (class-methods cls)))
	`(,@(cdrlist !)
      ,@(js-gen-inherit-methods class-name (!? (class-parent cls)
                                               (class-name !)))
      (hash-merge (slot-value ,class-name 'prototype)
	              (%%%make-hash-table ,@(apply #'+ (carlist !)))))))

(define-js-std-macro finalize-class (class-name)
  (print-definition `(finalize-class ,class-name))
  (let classes (thisify-classes)
    (!? (href classes class-name)
	    `{,(assoc-value class-name *delayed-constructors*)
		  ,@(js-emit-methods class-name !)}
	    (error "Cannot finalize undefined class ~A." class-name))))
