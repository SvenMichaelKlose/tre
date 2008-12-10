;;;;; TRE tree processor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Ducktyped objects

(defconstant *ducktype-magic* '%%QUACK-QUACK!)
(defconstant *ducktyped-classes* (make-hash-table))

(defstruct ducktyped-class
  (members nil)
  (methods nil))

(defstruct ducktyped-obj
  (magic *ducktyped-magic*)
  (slots nil)
  (members nil))

(defun ducktyped-slothash-name (objname)
  ($ '%%DUCKTYPED-SLOTS- objname))

(defun %ducktype-inherit (cname bases)
  (with (base-members nil
	     base-methods nil)
   	(dolist (base bases)
	  (let bclass (gethash base *ducktyped-classes*)
		(nconc base-members (ducktyped-class-members bclass))
		(nconc base-methods (ducktyped-class-methods bclass))))
	(make-ducktyped-class :members base-members
				     	  :methods base-methods)))

(defun %ducktype-make-class (cname bases)
  (when (gethash cname *ducktyped-classes*)
    (error "Class ~A already defined." cname))
  (setf (gethash cname *ducktyped-classes*)
   		(if bases
			(%ducktype-inherit cname bases)
			(make-ducktyped-class))))

(defmacro defclass (class-name args &rest body)
  (with (cname (if (consp class-name)
				   class-name.
				   class-name)
		 bases (and (consp class-name)
				    .class-name))
	(%ducktype-make-class cname bases)
	(with (slothash (ducktyped-slothash-name cname))
	  `(progn
	     (defvar ,slothash cname) (make-hash-table)
	     (setf (gethash '__class ,slothash) ,cname)
		 (setf (gethash cname *ducktype-slothashes*) ,slothash)
	     ; Inherit base class slots.
	     ,@(mapcar (fn (with (baseslots (ducktyped-slothash-name _))
	   				     `(dolist (i (hashkeys ,baseslots))
						    (setf (gethash i ,slothash)
								  (gethash i ,baseslots)))))
				   bases)
	     (defun ,cname this ,args
		   (%thisify ,cname
		     ,@body))))))

(defun %ducktype-assert-definition (what name class-name)
  (unless (gethash class-name *ducktyped-classes*)
	(error "Definition of ~A ~A: class ~A is not defined."
		   what name class-name)))

(defmacro defmethod (class-name name args &rest body)
  (%ducktype-assert-definition "method" name class-name)
  (setf (gethash name (gethash class-name *ducktype-slothashes*))
		(eval `#'(,args
			       (%thisify ,class-name
			         ,@body)))))

(defmacro defmember (class-name &rest names)
  (%ducktype-assert-definition "member" name class-name)
  (setf (gethash class-name *ducktype-members*)
		(append (gethash class-name *ducktype-members*) names)))

(defun %ducktyped-assert (obj)
  (unless (arrayp obj)
    (error "ducktyped object expected - not even an array"))
  (unless (eq *ducktype-magic* (aref obj 0))
    (error "ducktyped object expected")))

(defun %slot-value (obj slot)
  (%ducktyped-assert obj)
  (or (gethash slot (ducktyped-obj-slots obj))
	  (gethash slot (ducktyped-obj-members obj))))

(defun (setf %slot-value) (value obj slot)
  (%ducktyped-assert obj)
  (setf (gethash slot (ducktyped-obj-members obj)) value))

(defun %new (name &rest args)
  (let members (make-hash-table)
	(dolist (i (gethash name *ducktype-members*))
	  (clr (gethash i members)))
	(let this (make-ducktyped-obj
				:class name
				:slots (gethash name *ducktype-slothashes*)
				:members members)
	  (apply (symbol-function name) this args))))

(defmacro new (name &rest args)
  `(%new ',name ,@args))
