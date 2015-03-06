; tré – Copyright (c) 2008–2009,2011–2015 Sven Michael Klose <pixel@copei.de>

(defvar *classes* (make-hash-table :test #'eq))

(defstruct class
  name
  (methods nil)
  (members nil))

(defstruct object
  class
  slots)

(defun ducktype-inherited-members (classes)
  (apply #'hash-merge (@ [class-members (href *classes* _)]
                         (reverse classes))))

(defun ducktype-inherited-methods (classes)
  (| (apply #'hash-merge (@ [class-methods (href *classes* _)]
                            (reverse classes)))
     (make-hash-table :test #'eq)))

(defmacro defclass (classes args &body body)
  (print-definition `(defclass ,classes ,args))
  (= classes (ensure-list classes))
  (& (href *classes* classes.)
     (error "Class ~A already defined." classes.))
  (= (href *classes* classes.)
     (make-class :members (ducktype-inherited-members .classes)
                 :methods (ducktype-inherited-methods .classes)))
  `(defun ,classes. (this ,@args)
     (%thisify ,classes. ,@body)))

(defun %new (name &rest args)
  (with (class   (href *classes* name)
         object  (make-object :class class
                              :slots (copy-hash-table (class-methods class))))
    (apply (symbol-function name) object args)
    object))

(defmacro new (name &rest args)
  `(%new ',name ,@args))

(defun %ducktype-assert (x)
  (| (object? x)
     (error "Ducktype object expected instead of ~A." x)))

(defun %ducktype-assert-class (class-name)
  (| (href *classes* class-name)
     (error "Class ~A is not defined." class-name)))

(defmacro defmethod (class-name name args &body body)
  (print-definition `(defmethod ,class-name ,name ,args))
  (%ducktype-assert-class class-name)
  `(+! (href (class-methods (href *classes* ',class-name)) name)
       `(function (this ,@args)
          (%thisify ,class-name ,@body))))

(defmacro defmember (class-name &rest names)
  (print-definition `(defmember ,@names))
  (%ducktype-assert-class class-name)
  (| (href *classes* class-name) (error "Class ~A is not defined."))
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
