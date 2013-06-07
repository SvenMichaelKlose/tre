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
       (defun ,class-name ,args
         ,@(js-gen-inherited-constructor-calls bases)
         (let ~%this this
           (%thisify ,class-name ,@body)))
       ,@(js-gen-inherited-methods class-name bases)
	   (defun ,($ class-name '?) (x)
	     (%%native x " instanceof " ,(compiled-function-name-string *transpiler* class-name))))))

(define-js-std-macro defclass (class-name args &rest body)
  (apply #'transpiler_defclass #'js-gen-constructor class-name args body))

(define-js-std-macro defmethod (class-name name args &rest body)
  (apply #'transpiler_defmethod class-name name args body))

(define-js-std-macro defmember (class-name &rest names)
  (apply #'transpiler_defmember class-name names))

(defun js-emit-method (class-name x)
  `((%%native ,x.)
	#'(,.x.
		(%thisify ,class-name
		  (let ~%this this
	        ,@(| ..x. (list nil)))))))

(defun js-emit-methods (class-name cls)
  (awhen (class-methods cls)
	`(hash-merge (slot-value ,class-name 'prototype)
	             (%%%make-hash-table ,@(mapcan [js-emit-method class-name _] (reverse !))))))

(define-js-std-macro finalize-class (class-name)
  (let classes (transpiler-thisify-classes *transpiler*)
    (!? (href classes class-name)
	    `(progn
		   ,(assoc-value class-name *delayed-constructors*)
		   ,(js-emit-methods class-name !))
	    (error "Cannot finalize undefined class ~A." class-name))))
