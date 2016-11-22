; tré – Copyright (c) 2008–2016 Sven Michael Klose <pixel@copei.de>

(defun js-gen-inherit-methods (class-name bases)
  (@ [`(hash-merge (slot-value ,class-name 'prototype)
                   (slot-value ,_ 'prototype))]
     bases))

(defun js-gen-inherit-constructor-calls (bases)
  (@ [`((slot-value ,_ 'CALL) this)]
     bases))

(defun js-gen-constructor (class-name bases args body)
  (let magic (list 'quote ($ '__ class-name))
    `(progn
       (defun ,class-name ,args
         (%thisify ,class-name
           ; TOOD: Set 'super' instead.
           ,@(js-gen-inherit-constructor-calls bases)
           ,@body))
       ,@(js-gen-inherit-methods class-name bases)
       (declare-cps-exception ,($ class-name '?))
	   (defun ,($ class-name '?) (x)
	     (%%native x " instanceof " ,(compiled-function-name-string class-name))))))

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
      (hash-merge (slot-value ,class-name 'prototype)
	              (%%%make-hash-table ,@(apply #'+ (carlist !)))))))

(define-js-std-macro finalize-class (class-name)
  (print-definition `(finalize-class ,class-name))
  (let classes (thisify-classes)
    (!? (href classes class-name)
	    `(progn
		   ,(assoc-value class-name *delayed-constructors*)
		   ,@(js-emit-methods class-name !))
	    (error "Cannot finalize undefined class ~A." class-name))))
