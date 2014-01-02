;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun js-gen-inherited-methods (class-name bases)
  (filter ^(hash-merge (slot-value ,class-name 'prototype)
                       (slot-value ,_ 'prototype))
          bases))

(defun js-gen-inherited-constructor-calls (bases)
  (filter ^((slot-value ,_ 'CALL) this) bases))

(defun js-gen-constructor (class-name bases args body)
  (let magic (list 'quote ($ '__ class-name))
    `(progn
       (declare-cps-exception ,class-name)
       (defun ,class-name ,args
         ,@(js-gen-inherited-constructor-calls bases)
         (%thisify ,class-name ,@body))
       ,@(js-gen-inherited-methods class-name bases)
       (declare-cps-exception ,($ class-name '?))
	   (defun ,($ class-name '?) (x)
	     (%%native x " instanceof " ,(compiled-function-name-string class-name))))))

(define-js-std-macro defclass (class-name args &rest body)
  (apply #'generic-defclass #'js-gen-constructor class-name args body))

(define-js-std-macro defmethod (class-name name args &rest body)
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
  (awhen (filter [js-emit-method class-name _]
                 (reverse (class-methods cls)))
	`(,@(cdrlist !)
      (hash-merge (slot-value ,class-name 'prototype)
	              (%%%make-hash-table ,@(apply #'+ (carlist !)))))))

(define-js-std-macro finalize-class (class-name)
  (let classes (transpiler-thisify-classes *transpiler*)
    (!? (href classes class-name)
	    `(progn
		   ,(assoc-value class-name *delayed-constructors*)
		   ,@(js-emit-methods class-name !))
	    (error "Cannot finalize undefined class ~A." class-name))))
