;;;;; tré – Copyright (c) 2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defvar *classes* (make-hash-table :test #'eq))

(defstruct class
  name
  (methods nil)
  (members nil))

(defstruct object
  class
  slots)

(defun %quote? (x))

(defmacro defclass (classes args &rest body)
  (print-definition `(defclass ,classes ,args))
  (= classes (force-list classes))
  (print classes)
  (print (reverse .classes))
  (& (href *classes* classes.)
     (error "Class ~A already defined." classes.))
  (= (href *classes* classes.) (make-class :members (apply #'hash-merge (filter [class-members (href *classes* _)] (reverse .classes)))
	                                       :methods (| (apply #'hash-merge (filter [class-methods (href *classes* _)] (reverse .classes)))
                                                       (make-hash-table :test #'eq))))
  (thisify *classes* `(defun ,classes. (this ,@args)
			            (%thisify ,classes. ,@body))))

(defun %new (name &rest args)
  (with (class  (href *classes* name)
         object (make-object :class class
                             :slots (copy-hash-table (class-methods class))))
    (apply (symbol-function name) object args)
    object))

(defmacro new (name &rest args)
  `(%new ',name ,@args))

(defun %ducktype-assert (x)
  (| (object? x)
     (error "ducktype object expected instead of ~A" x)))

(defun %ducktype-assert-class (class-name)
  (| (href *classes* class-name) (error "class ~A is not defined" class-name)))

(defmacro defmethod (class-name name args &rest body)
  (print-definition `(defmethod ,class-name ,name ,args))
  (%ducktype-assert-class class-name)
  `(+! (href (class-methods (href *classes* ',class-name)) name)
       (function ,(thisify *classes* `((this ,@args)
                                         (%thisify ,class-name ,@body))))))

(defmacro defmember (class-name &rest names)
  (print-definition `(defmember ,@names))
  (%ducktype-assert-class class-name)
  (| (href *classes* class-name) (error "class ~A is not defined"))
;  (+! (class-members (href *classes* class-name)) names)
  nil)

(defun %slot-value (obj slot)
  (%ducktype-assert obj)
  (href (object-slots obj) slot))

(defun slot-value (obj slot)
  (%ducktype-assert obj)
  (href (object-slots obj) slot))

(defun (= %slot-value) (value obj slot)
  (%ducktype-assert obj)
  (= (href (object-slots obj) slot) value))

(defun (= slot-value) (value obj slot)
  (%ducktype-assert obj)
  (= (href (object-slots obj) .slot.) value))
