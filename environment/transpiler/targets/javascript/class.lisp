;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun js-make-constructor (cname bases args body)
  (let magic (list 'quote ($ '__ cname))
    `(progn
       (defun ,cname ,args
         (= (slot-value this ,magic) t)
         ; Inject calls to base constructors.
         ,@(filter ^((slot-value ,_ 'CALL) this) bases)
         (let ~%this this
           (%thisify ,cname
             ,@(ignore-body-doc body))))

       ; Inherit base class prototypes.
       ,@(filter ^(hash-merge (slot-value ,cname 'PROTOTYPE)
                              (slot-value ,_ 'PROTOTYPE))
		         bases)

	   ; Make predicate.
	   (defun ,($ cname '?) (x)
	     (& (object? x)
            (defined? (slot-value x ,magic))
            x)))))

(define-js-std-macro defclass (class-name args &rest body)
  (apply #'transpiler_defclass #'js-make-constructor class-name args body))

(define-js-std-macro defmethod (class-name name args &rest body)
  (apply #'transpiler_defmethod class-name name args body))

(define-js-std-macro defmember (class-name &rest names)
  (apply #'transpiler_defmember class-name names))

(defun js-emit-method (class-name x)
  `((%transpiler-native ,x.)
	#'(,.x.
		(%thisify ,class-name
		  (let ~%this this
	        ,@(| (ignore-body-doc ..x.) (list nil)))))))

(defun js-emit-methods (class-name cls)
  (awhen (class-methods cls)
	`(hash-merge (slot-value ,class-name 'PROTOTYPE)
	             (%%%make-hash-table ,@(mapcan [js-emit-method class-name _] (reverse !))))))

(define-js-std-macro finalize-class (class-name)
  (let classes (transpiler-thisify-classes *transpiler*)
    (!? (href classes class-name)
	    `(progn
		   ,(assoc-value class-name *delayed-constructors*)
		   ,(js-emit-methods class-name !))
	    (error "Cannot finalize undefined class ~A." class-name))))
